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
variable "artifact_type" {
  description = "artifactの取得方法（local or s3）"
  type        = string
  default     = "local"
  validation {
    condition     = contains(["local", "s3"], var.artifact_type)
    error_message = "artifact_type は local または s3 を指定してください。"
  }
}

variable "artifact_path" {
  description = "ローカルzipのパス"
  type        = string
  default     = "artifacts/lambda-api/dummy-lambda-api.zip"
}

variable "s3_bucket" {
  description = "S3のバケット名"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3のオブジェクトキー"
  type        = string
  default     = ""
}

variable "s3_object_version" {
  description = "S3オブジェクトのバージョン（任意）"
  type        = string
  default     = ""
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
variable "environment_variables" {
  description = "Lambda環境変数"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Lambda/Logsに付与するタグ"
  type        = map(string)
  default     = {}
}
