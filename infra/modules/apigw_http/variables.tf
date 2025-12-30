# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "HTTP APIリソース名のプレフィックス"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "API Gateway統合で使うLambdaのinvoke ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda関数名（権限設定に利用）"
  type        = string
}

variable "jwt_issuer" {
  description = "Cognito JWT issuer"
  type        = string
}

variable "jwt_audience" {
  description = "Cognito JWT audience（client id）"
  type        = list(string)
}

# --------------------------------------------------
# variables: cors
# --------------------------------------------------
variable "cors_allow_origins" {
  description = "CORS許可オリジン"
  type        = list(string)
}

variable "cors_allow_methods" {
  description = "CORS許可メソッド"
  type        = list(string)
  default     = ["GET", "POST", "PATCH", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "CORS許可ヘッダー"
  type        = list(string)
  default     = ["authorization", "content-type"]
}

variable "cors_expose_headers" {
  description = "CORS公開ヘッダー"
  type        = list(string)
  default     = []
}

variable "cors_allow_credentials" {
  description = "CORSでクレデンシャルを許可するか"
  type        = bool
  default     = false
}

variable "cors_max_age" {
  description = "CORS preflightのキャッシュ秒数"
  type        = number
  default     = 3600
}

# --------------------------------------------------
# variables: stage / integration / tags
# --------------------------------------------------
variable "stage_name" {
  description = "API Gatewayステージ名"
  type        = string
  default     = "$default"
}

variable "integration_timeout_milliseconds" {
  description = "Lambda統合のタイムアウト（ms）"
  type        = number
  default     = 30000  # 30秒
}

variable "tags" {
  description = "API Gatewayに付与するタグ"
  type        = map(string)
  default     = {}
}
