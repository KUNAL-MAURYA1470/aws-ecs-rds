output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "service_security_group_id" {
  description = "Security group ID for ECS service tasks."
  value       = aws_security_group.service.id
}

