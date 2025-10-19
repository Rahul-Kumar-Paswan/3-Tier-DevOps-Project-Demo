output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.devsecops_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for s in aws_subnet.public_subnet : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for s in aws_subnet.private_subnet : s.id]
}
