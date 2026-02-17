output "db_endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Database username."
  value       = aws_db_instance.this.username
}

output "security_group_id" {
  description = "Security group ID for the RDS instance."
  value       = aws_security_group.db.id
}

output "db_secret_arn" {
  description = "Secrets Manager secret ARN for RDS credentials."
  value       = aws_secretsmanager_secret.db.arn
}

