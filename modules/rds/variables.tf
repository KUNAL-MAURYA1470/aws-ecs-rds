variable "name_prefix" {
  description = "Prefix used for naming RDS resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS."
  type        = list(string)
}

variable "db_instance_class" {
  description = "Instance class for the PostgreSQL RDS instance."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for the PostgreSQL RDS instance (GiB)."
  type        = number
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Master database username."
  type        = string
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ for RDS."
  type        = bool
}

variable "rotation_lambda_filename" {
  description = "Path to the zip file for the RDS rotation Lambda."
  type        = string
}

variable "rotation_lambda_subnet_ids" {
  description = "Subnet IDs where the rotation Lambda runs."
  type        = list(string)
}

variable "rotation_lambda_security_group_ids" {
  description = "Security group IDs for the rotation Lambda."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to RDS resources."
  type        = map(string)
  default     = {}
}

