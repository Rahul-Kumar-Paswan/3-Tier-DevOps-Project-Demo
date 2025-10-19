provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "3-tier-devsecops-terraform"
    key    = "Terraform/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "vpc" {
  source                           = "./modules/vpcs"
  tags                             = var.tags
  Name                             = var.Name
  vpc_cidr                         = var.vpc_cidr
  environment                      = var.environment
  public_subnet_cidrs              = var.public_subnet_cidrs
  private_subnet_cidrs             = var.private_subnet_cidrs
  public_subnet_availability_zones = var.public_subnet_availability_zones
  private_subnet_availability_zones = var.private_subnet_availability_zones
}

module "eks" {
  source               = "./modules/eks"
  tags                 = var.tags
  Name                 = var.Name
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  eks_version          = var.eks_version
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  desired_worker_count = var.desired_worker_count
  min_worker_count     = var.min_worker_count
  max_worker_count     = var.max_worker_count
  node_instance_type   = var.node_instance_type
}

module "ec2_instances" {
  source            = "./modules/ec2"
  tags              = var.tags
  Name              = var.Name
  instance_type     = var.instance_type
  environment       = var.environment
  key_name          = var.key_name
  vpc_id            = module.vpc.vpc_id
  volume_size       = var.volume_size
  volume_type       = var.volume_type
  public_subnet_ids = module.vpc.public_subnet_ids
}


provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
  }
}
