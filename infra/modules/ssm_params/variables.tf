# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "SSM Parameterのプレフィックス"
  type        = string
}

variable "slack_webhook_param_name" {
  description = "Slack Webhook用SSM Parameter名"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL"
  type        = string
  sensitive   = true
}

variable "weather_location_param_name" {
  description = "天気通知の地域用SSM Parameter名"
  type        = string
}

variable "weather_location" {
  description = "天気通知の地域"
  type        = string
}

variable "tags" {
  description = "SSM Parameterに付与するタグ"
  type        = map(string)
  default     = {}
}
