variable "tags" {
  type = map(string)
}

variable "Name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name (PEM file)"
  type        = string
}

variable "volume_size" {
  description = "Root volume size (GB)"
  type        = number
}

variable "volume_type" {
  description = "Root volume type"
  type        = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for EC2 security group"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "CIDR block to allow SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "sonarqube_allowed_ips" {
  description = "CIDR block to allow SonarQube access"
  type        = string
  default     = "0.0.0.0/0"
}
