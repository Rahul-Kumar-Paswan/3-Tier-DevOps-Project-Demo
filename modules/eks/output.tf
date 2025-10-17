output "eks_cluster_name" {
  value = aws_eks_cluster.devsecops_eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.devsecops_eks_cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.devsecops_eks_cluster.arn
}

output "node_group_name" {
  value = aws_eks_node_group.worker_nodes.node_group_name
}

output "jenkins_irsa_role_arn" {
  value = aws_iam_role.jenkins_irsa_role.arn
  description = "IAM role ARN associated with Jenkins IRSA service account"
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.devsecops_eks_cluster.certificate_authority[0].data
}