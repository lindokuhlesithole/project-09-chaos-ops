variable "app_name" {
  description = "Application name"
  type        = string
  default     = "chaosops2026"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
  default     = ""
}
