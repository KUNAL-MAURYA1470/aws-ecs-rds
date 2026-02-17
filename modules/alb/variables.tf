variable "name_prefix" {
  description = "Prefix used for naming ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ALB is deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB."
  type        = list(string)
}

variable "idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to ALB resources."
  type        = map(string)
  default     = {}
}

