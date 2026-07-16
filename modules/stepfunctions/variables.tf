variable "app_name" { type = string }
variable "pre_check_arn" { type = string }
variable "chaos_inject_arn" { type = string }
variable "post_check_arn" { type = string }
variable "score_arn" { type = string }
variable "dynamodb_table" { type = string }
variable "sns_topic_arn" { type = string }
