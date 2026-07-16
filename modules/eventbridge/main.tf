resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-schedule"
  description         = "Trigger chaos experiment daily"
  schedule_expression = "rate(1 day)"
  tags                = { Name = "${var.app_name}-schedule" }
}

resource "aws_cloudwatch_event_target" "sfn" {
  rule     = aws_cloudwatch_event_rule.schedule.name
  arn      = var.state_machine_arn
  role_arn = aws_iam_role.eventbridge.arn
}

resource "aws_iam_role" "eventbridge" {
  name = "${var.app_name}-eventbridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.app_name}-eventbridge-role" }
}

resource "aws_iam_role_policy" "eventbridge" {
  name = "${var.app_name}-eventbridge-policy"
  role = aws_iam_role.eventbridge.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = var.state_machine_arn
    }]
  })
}
