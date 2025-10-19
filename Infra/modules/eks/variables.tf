variable "tags" {
  type = map(string)
}

variable "Name" {
  type = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "desired_worker_count" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_worker_count" {
  type = number
}

variable "max_worker_count" {
  type = number
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "namespace" {
  description = "Namespace for Jenkins service account"
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "Jenkins service account Name"
  type        = string
  default     = "jenkins"
}