resource "aws_dynamodb_table" "history" {
  name         = "${var.app_name}-history"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "experimentId"
  range_key    = "timestamp"

  attribute {
    name = "experimentId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "score"
    type = "N"
  }

  global_secondary_index {
    name            = "score-index"
    hash_key        = "experimentId"
    range_key       = "score"
    projection_type = "ALL"
  }

  tags = { Name = "${var.app_name}-history" }
}
