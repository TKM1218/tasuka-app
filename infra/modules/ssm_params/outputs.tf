# --------------------------------------------------
# outputs: ssm params
# --------------------------------------------------
output "slack_webhook_param_name" {
  description = "Slack Webhook用SSM Parameter名"
  value       = aws_ssm_parameter.slack_webhook.name
}

output "slack_webhook_param_arn" {
  description = "Slack Webhook用SSM Parameter ARN"
  value       = aws_ssm_parameter.slack_webhook.arn
}

output "weather_location_param_name" {
  description = "天気通知の地域用SSM Parameter名"
  value       = aws_ssm_parameter.weather_location.name
}

output "weather_location_param_arn" {
  description = "天気通知の地域用SSM Parameter ARN"
  value       = aws_ssm_parameter.weather_location.arn
}
