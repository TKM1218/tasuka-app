# --------------------------------------------------
# outputs: lambda role
# --------------------------------------------------
output "lambda_role_arn" {
  description = "Lambda実行ロールのARN"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "Lambda実行ロール名"
  value       = aws_iam_role.lambda.name
}

# --------------------------------------------------
# outputs: policy
# --------------------------------------------------
output "policy_arn" {
  description = "Lambda用IAMポリシーのARN"
  value       = aws_iam_policy.lambda.arn
}
