output "sonarqube_id" {
  description = "ID of SonarQube instance"
  value       = aws_instance.sonarqube.id
}

output "sonarqube_public_ip" {
  description = "Public IP of SonarQube instance"
  value       = aws_instance.sonarqube.public_ip
}

output "sonarqube_private_ip" {
  description = "Private IP of SonarQube instance"
  value       = aws_instance.sonarqube.private_ip
}
