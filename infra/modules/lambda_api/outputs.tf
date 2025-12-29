# --------------------------------------------------
# outputs: lambda api
# --------------------------------------------------
output "function_name" {
  description = "API Lambdaの関数名"
  value       = aws_lambda_function.api.function_name
}

output "function_arn" {
  description = "API LambdaのARN"
  value       = aws_lambda_function.api.arn
}

output "invoke_arn" {
  description = "API Gateway統合で使うinvoke ARN"
  value       = aws_lambda_function.api.invoke_arn
}
