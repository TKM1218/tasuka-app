# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# AWS provider profile selection for local runs.
variable "aws_profile" {
  description = "AWS CLI profile name for the dev environment"
  type        = string
}

# --------------------------------------------------
# variables: common tags
# --------------------------------------------------
variable "tags" {
  description = "Common tags for all resources in this environment"
  type        = map(string)
  default     = {}
}

# --------------------------------------------------
# variables: cognito
# --------------------------------------------------
variable "cognito_hosted_ui_domain_prefix" {
  description = "Cognito Hosted UIのドメインプレフィックス。"
  type        = string
}

variable "cognito_callback_urls" {
  description = "CognitoのOAuth callback URL一覧。"
  type        = list(string)
}

variable "cognito_logout_urls" {
  description = "CognitoのOAuth logout URL一覧。"
  type        = list(string)
}

# --------------------------------------------------
# variables: ssm params
# --------------------------------------------------
variable "slack_webhook_url" {
  description = "Slack Webhook URL（SSMに保存する値）"
  type        = string
  sensitive   = true
}

variable "weather_location" {
  description = "天気通知の地域（SSMに保存する値）"
  type        = string
}

# --------------------------------------------------
# variables: terraform state
# --------------------------------------------------
variable "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state storage."
  type        = string
}

variable "tfstate_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}

# --------------------------------------------------
# variables: scheduler
# --------------------------------------------------
variable "scheduler_schedule_expression" {
  description = "EventBridge Schedulerのcronまたはrate式"
  type        = string
}

variable "scheduler_target_input" {
  description = "SchedulerがLambdaへ渡す入力（JSON文字列 or map）"
  type        = any
  default     = null
}
