# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "IAMリソース名のプレフィックス"
  type        = string
}

# --------------------------------------------------
# variables: access scope
# --------------------------------------------------
variable "dynamodb_table_arns" {
  description = "LambdaがアクセスするDynamoDBテーブルのARN一覧"
  type        = list(string)
}

variable "ssm_param_arns" {
  description = "Lambdaが参照するSSM ParameterのARN一覧"
  type        = list(string)
  default     = []
}

variable "secretsmanager_arns" {
  description = "Lambdaが参照するSecrets ManagerのARN一覧"
  type        = list(string)
  default     = []
}

# --------------------------------------------------
# variables: common tags
# --------------------------------------------------
variable "tags" {
  description = "IAMリソースに付与するタグ"
  type        = map(string)
  default     = {}
}
