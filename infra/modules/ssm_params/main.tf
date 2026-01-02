# --------------------------------------------------
# ssm params: slack webhook / weather location
# --------------------------------------------------
resource "aws_ssm_parameter" "slack_webhook" {
  name  = var.slack_webhook_param_name
  type  = "SecureString"
  value = var.slack_webhook_url
  tags  = var.tags
}

resource "aws_ssm_parameter" "weather_location" {
  name  = var.weather_location_param_name
  type  = "String"
  value = var.weather_location
  tags  = var.tags
}
