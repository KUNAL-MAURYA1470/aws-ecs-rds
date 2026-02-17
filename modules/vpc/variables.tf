variable "name_prefix" {
  description = "Prefix used for naming VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "List of availability zones to use. If empty, the provider default AZs will be used."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Map of public subnet CIDR blocks."
  type        = map(string)
}

variable "private_subnet_cidrs" {
  description = "Map of private subnet CIDR blocks."
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to VPC resources."
  type        = map(string)
  default     = {}
}

