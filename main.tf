module "dynamodb" {
  source   = "./modules/dynamodb"
  app_name = var.app_name
}

module "sns" {
  source      = "./modules/sns"
  app_name    = var.app_name
  alert_email = var.alert_email
}

module "lambda" {
  source         = "./modules/lambda"
  app_name       = var.app_name
  aws_region     = var.aws_region
  sns_topic_arn  = module.sns.topic_arn
  dynamodb_table = module.dynamodb.table_name
}

module "stepfunctions" {
  source            = "./modules/stepfunctions"
  app_name          = var.app_name
  pre_check_arn     = module.lambda.pre_check_arn
  chaos_inject_arn  = module.lambda.chaos_inject_arn
  post_check_arn    = module.lambda.post_check_arn
  score_arn         = module.lambda.score_arn
  dynamodb_table    = module.dynamodb.table_name
  sns_topic_arn     = module.sns.topic_arn
}

module "eventbridge" {
  source              = "./modules/eventbridge"
  app_name            = var.app_name
  state_machine_arn   = module.stepfunctions.state_machine_arn
}
