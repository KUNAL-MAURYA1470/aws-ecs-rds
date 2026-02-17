variable "name_prefix" {
  description = "Prefix used for naming IAM and logging resources."
  type        = string
}

variable "ecs_task_execution_policies" {
  description = "List of managed policy ARNs attached to the ECS task execution role."
  type        = list(string)
  default     = []
}

variable "ecs_task_additional_policies" {
  description = "Additional managed policy ARNs attached to the ECS task role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to IAM and logging resources."
  type        = map(string)
  default     = {}
}

