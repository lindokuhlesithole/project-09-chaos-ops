output "pre_check_arn" { value = aws_lambda_function.pre_check.arn }
output "chaos_inject_arn" { value = aws_lambda_function.chaos_inject.arn }
output "chaos_lambda_arn" { value = aws_lambda_function.chaos_inject.arn }
output "post_check_arn" { value = aws_lambda_function.post_check.arn }
output "score_arn" { value = aws_lambda_function.score.arn }
