variable "name_prefix" {
  description = "Prefix used for naming ECS resources."
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS is deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
}

variable "ecs_min_capacity" {
  description = "Minimum ECS task capacity."
  type        = number
}

variable "ecs_max_capacity" {
  description = "Maximum ECS task capacity."
  type        = number
}

variable "container_cpu" {
  description = "CPU units for ECS task."
  type        = number
}

variable "container_memory" {
  description = "Memory (MiB) for ECS task."
  type        = number
}

variable "container_port" {
  description = "Container port to expose."
  type        = number
}

variable "container_image" {
  description = "ECR image URI for ECS task."
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB."
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role."
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS."
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager secret ARN for database credentials."
  type        = string
}

variable "db_hostname" {
  description = "Database endpoint hostname."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "tags" {
  description = "Tags to apply to ECS resources."
  type        = map(string)
  default     = {}
}

