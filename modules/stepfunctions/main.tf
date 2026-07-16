locals {
  asl = jsonencode({
    "Comment" = "Chaos Engineering Experiment",
    "StartAt" = "PreCheck",
    "States" = {
      "PreCheck" = {
        "Type"     = "Task",
        "Resource" = var.pre_check_arn,
        "Next"     = "ChaosInject"
      },
      "ChaosInject" = {
        "Type"     = "Task",
        "Resource" = var.chaos_inject_arn,
        "Next"     = "Wait"
      },
      "Wait" = {
        "Type"    = "Wait",
        "Seconds" = 30,
        "Next"    = "PostCheck"
      },
      "PostCheck" = {
        "Type"     = "Task",
        "Resource" = var.post_check_arn,
        "Next"     = "Score"
      },
      "Score" = {
        "Type"     = "Task",
        "Resource" = var.score_arn,
        "Next"     = "Notify",
        "ResultPath" = "$.scoreResult"
      },
      "Notify" = {
        "Type"     = "Task",
        "Resource" = "arn:aws:states:::sns:publish",
        "Parameters" = {
          "TopicArn" = var.sns_topic_arn,
          "Message"  = {
            "experimentId.$" = "$.experimentId",
            "score.$"        = "$.scoreResult.score",
            "timestamp.$"    = "$$.State.EnteredTime"
          }
        },
        "End" = true
      }
    }
  })
}

resource "aws_iam_role" "sfn" {
  name = "${var.app_name}-sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
  tags = { Name = "${var.app_name}-sfn-role" }
}

resource "aws_iam_role_policy" "sfn" {
  name = "${var.app_name}-sfn-policy"
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.pre_check_arn,
          var.chaos_inject_arn,
          var.post_check_arn,
          var.score_arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "main" {
  name     = var.app_name
  role_arn = aws_iam_role.sfn.arn
  definition = local.asl
  tags = { Name = var.app_name }
}
