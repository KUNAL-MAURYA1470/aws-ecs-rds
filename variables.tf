variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "project_name" {
  description = "Short project name used for resource naming."
  type        = string
  default     = "ecs-rds-app"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Map of public subnet CIDR blocks keyed by AZ suffix or name."
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Map of private subnet CIDR blocks keyed by AZ suffix or name."
  type        = map(string)
  default = {
    a = "10.0.11.0/24"
    b = "10.0.12.0/24"
  }
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 2
}

variable "ecs_min_capacity" {
  description = "Minimum ECS task capacity for autoscaling."
  type        = number
  default     = 2
}

variable "ecs_max_capacity" {
  description = "Maximum ECS task capacity for autoscaling."
  type        = number
  default     = 6
}

variable "ecs_container_cpu" {
  description = "CPU units for the ECS task definition."
  type        = number
  default     = 512
}

variable "ecs_container_memory" {
  description = "Memory (MiB) for the ECS task definition."
  type        = number
  default     = 1024
}

variable "ecs_container_port" {
  description = "Container port exposed by the ECS task."
  type        = number
  default     = 8080
}

variable "ecs_task_image" {
  description = "ECR image URI for the ECS task."
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the PostgreSQL RDS instance."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the PostgreSQL RDS instance (GiB)."
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master database username."
  type        = string
  default     = "app_user"
}

variable "db_backup_retention_period" {
  description = "Number of days to retain RDS backups."
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ for RDS."
  type        = bool
  default     = true
}

variable "db_rotation_lambda_filename" {
  description = "Path to the zip file for the RDS rotation Lambda."
  type        = string
  default     = "./lambda/rds-rotation.zip"
}

variable "alb_idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "waf_rate_limit" {
  description = "Request rate limit for WAF rate-based rule."
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Base tags to apply to all resources."
  type        = map(string)
  default     = {}
}

