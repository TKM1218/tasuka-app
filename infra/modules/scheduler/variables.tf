# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "Schedulerリソース名のプレフィックス"
  type        = string
}

variable "schedule_expression" {
  description = "cron または rate のスケジュール式"
  type        = string
}

variable "timezone" {
  description = "スケジュールのタイムゾーン"
  type        = string
  default     = "Asia/Tokyo"
}

variable "target_lambda_arn" {
  description = "呼び出し対象のLambda ARN"
  type        = string
}

variable "target_input" {
  description = "Lambdaへ渡す入力（JSON文字列 or map）"
  type        = any
  default     = null
}

variable "tags" {
  description = "Schedulerに付与するタグ"
  type        = map(string)
  default     = {}
}
