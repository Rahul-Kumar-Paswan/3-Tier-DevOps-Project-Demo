# IAM ROLE FOR EKS CLUSTER

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# EKS CLUSTER

resource "aws_eks_cluster" "devsecops_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.public_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = merge(var.tags, {
    Name = "${var.eks_cluster_name}-eks-cluster"
  })
}


# IAM ROLE FOR NODE GROUP

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.eks_cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# EKS NODE GROUP

resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.devsecops_eks_cluster.name
  node_group_name = "${var.eks_cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.public_subnet_ids

  scaling_config {
    desired_size = var.desired_worker_count
    min_size     = var.min_worker_count
    max_size     = var.max_worker_count
  }

  instance_types = [var.node_instance_type]

  depends_on = [aws_eks_cluster.devsecops_eks_cluster]
}


# OIDC PROVIDER FOR IRSA

data "aws_eks_cluster" "cluster_info" {
  name = aws_eks_cluster.devsecops_eks_cluster.name
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster_info.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster_info.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}


# IAM ROLE FOR EBS CSI DRIVER (IRSA)

resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${var.eks_cluster_name}-ebs-csi-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster_info.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


# EBS CSI ADDON WITH IRSA ROLE

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.devsecops_eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.worker_nodes,
    aws_iam_role_policy_attachment.ebs_csi_attach
  ]
}


#  IRSA FOR JENKINS SERVICE ACCOUNT

# Fetch existing EKS Cluster info
data "aws_eks_cluster" "jenkins_cluster" {
  name = aws_eks_cluster.devsecops_eks_cluster.name
}

data "aws_eks_cluster_auth" "jenkins_auth" {
  name = aws_eks_cluster.devsecops_eks_cluster.name
}

# IAM Policy for Jenkins
resource "aws_iam_policy" "jenkins_irsa_policy" {
  name        = "jenkins-irsa-policy"
  description = "IAM policy for Jenkins pod to access AWS resources"
  policy      = file("${path.module}/policies/jenkins-irsa-policy.json")
}

# IAM Role for Jenkins IRSA
resource "aws_iam_role" "jenkins_irsa_role" {
  name = "${var.eks_cluster_name}-jenkins-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster_info.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

# Attach Jenkins policy
resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_irsa_role.name
  policy_arn = aws_iam_policy.jenkins_irsa_policy.arn
}

# Create Namespace in Kubernetes
resource "kubernetes_namespace" "jenkins" {
  count = var.namespace == "default" ? 0 : 1

  metadata {
    name = var.namespace
  }
}


# Create Jenkins Service Account in Kubernetes
resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace  # use the raw variable
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_irsa_role.arn
    }
  }

  depends_on = [aws_eks_cluster.devsecops_eks_cluster]
}

