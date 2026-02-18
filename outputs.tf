output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = module.alb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint address."
  value       = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN for the RDS credentials."
  value       = module.rds.db_secret_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.ecs.service_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = module.ecr.repository_url
}

