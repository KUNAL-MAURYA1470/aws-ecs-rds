variable "name_prefix" {
  description = "Prefix used for WAF resources."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to protect."
  type        = string
}

variable "rate_limit" {
  description = "Request rate limit for the rate-based rule."
  type        = number
}

variable "scope" {
  description = "Scope of the WAF (REGIONAL or CLOUDFRONT)."
  type        = string
  default     = "REGIONAL"
}

variable "tags" {
  description = "Tags to apply to WAF resources."
  type        = map(string)
  default     = {}
}

