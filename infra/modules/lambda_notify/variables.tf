# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "Lambdaリソース名のプレフィックス"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda実行ロールのARN"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime（Node.js）"
  type        = string
  default     = "nodejs20.x"
}

# --------------------------------------------------
# variables: artifact
# --------------------------------------------------
variable "artifact_path_due" {
  description = "通知（期限）Lambdaのローカルzipパス"
  type        = string
  default     = "artifacts/lambda-notify/dummy-notify.zip"
}

variable "artifact_path_weather" {
  description = "通知（天気）Lambdaのローカルzipパス"
  type        = string
  default     = "artifacts/lambda-notify/dummy-notify.zip"
}

# --------------------------------------------------
# variables: runtime tuning
# --------------------------------------------------
variable "memory_size" {
  description = "Lambdaメモリサイズ（MB）"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambdaタイムアウト（秒）"
  type        = number
  default     = 10
}

variable "log_retention_in_days" {
  description = "CloudWatch Logsの保持日数"
  type        = number
  default     = 30
}

# --------------------------------------------------
# variables: environment and tags
# --------------------------------------------------
variable "due_environment_variables" {
  description = "通知（期限）Lambda環境変数"
  type        = map(string)
  default     = {}
}

variable "weather_environment_variables" {
  description = "通知（天気）Lambda環境変数"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Lambda/Logsに付与するタグ"
  type        = map(string)
  default     = {}
}
