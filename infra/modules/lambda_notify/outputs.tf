# --------------------------------------------------
# outputs: notify due
# --------------------------------------------------
output "notify_due_function_name" {
  description = "通知（期限）Lambdaの関数名"
  value       = aws_lambda_function.notify_due.function_name
}

output "notify_due_function_arn" {
  description = "通知（期限）LambdaのARN"
  value       = aws_lambda_function.notify_due.arn
}

output "notify_due_invoke_arn" {
  description = "通知（期限）Lambdaのinvoke ARN"
  value       = aws_lambda_function.notify_due.invoke_arn
}

# --------------------------------------------------
# outputs: notify weather
# --------------------------------------------------
output "notify_weather_function_name" {
  description = "通知（天気）Lambdaの関数名"
  value       = aws_lambda_function.notify_weather.function_name
}

output "notify_weather_function_arn" {
  description = "通知（天気）LambdaのARN"
  value       = aws_lambda_function.notify_weather.arn
}

output "notify_weather_invoke_arn" {
  description = "通知（天気）Lambdaのinvoke ARN"
  value       = aws_lambda_function.notify_weather.invoke_arn
}
