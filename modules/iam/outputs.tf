output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role."
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_log_group_name" {
  description = "Name of the CloudWatch log group for ECS."
  value       = aws_cloudwatch_log_group.ecs.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.app.bucket
}

