locals {
  functions = {
    pre_check    = file("${path.module}/pre_check.py")
    chaos_inject = file("${path.module}/chaos_inject.py")
    post_check   = file("${path.module}/post_check.py")
    score        = file("${path.module}/score.py")
  }
}

data "archive_file" "pre_check" {
  type        = "zip"
  output_path = "${path.module}/pre_check.zip"
  source {
    content  = local.functions["pre_check"]
    filename = "index.py"
  }
}

data "archive_file" "chaos_inject" {
  type        = "zip"
  output_path = "${path.module}/chaos_inject.zip"
  source {
    content  = local.functions["chaos_inject"]
    filename = "index.py"
  }
}

data "archive_file" "post_check" {
  type        = "zip"
  output_path = "${path.module}/post_check.zip"
  source {
    content  = local.functions["post_check"]
    filename = "index.py"
  }
}

data "archive_file" "score" {
  type        = "zip"
  output_path = "${path.module}/score.zip"
  source {
    content  = local.functions["score"]
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.app_name}-lambda-role" }
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.app_name}-lambda-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_table}"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_lambda_function" "pre_check" {
  function_name = "${var.app_name}-pre-check"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.pre_check.output_path
  source_code_hash = data.archive_file.pre_check.output_base64sha256
  timeout       = 30
  tags = { Name = "${var.app_name}-pre-check" }
}

resource "aws_lambda_function" "chaos_inject" {
  function_name = "${var.app_name}-chaos-inject"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.chaos_inject.output_path
  source_code_hash = data.archive_file.chaos_inject.output_base64sha256
  timeout       = 60
  tags = { Name = "${var.app_name}-chaos-inject" }
}

resource "aws_lambda_function" "post_check" {
  function_name = "${var.app_name}-post-check"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.post_check.output_path
  source_code_hash = data.archive_file.post_check.output_base64sha256
  timeout       = 30
  tags = { Name = "${var.app_name}-post-check" }
}

resource "aws_lambda_function" "score" {
  function_name = "${var.app_name}-score"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.score.output_path
  source_code_hash = data.archive_file.score.output_base64sha256
  timeout       = 30
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }
  tags = { Name = "${var.app_name}-score" }
}
