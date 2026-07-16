output "step_function_arn" {
  value = module.stepfunctions.state_machine_arn
}

output "experiment_table" {
  value = module.dynamodb.table_name
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "chaos_lambda" {
  value = module.lambda.chaos_lambda_arn
}

output "schedule_rule" {
  value = module.eventbridge.schedule_rule
}
