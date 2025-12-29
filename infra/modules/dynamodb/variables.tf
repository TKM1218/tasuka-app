# -------------------------------
# variables: basic settings
# -------------------------------
variable "name_prefix" {
  description = "DynamoDBのリソース名プレフィックス"
  type        = string
}

# -------------------------------
# variables: common tags
# -------------------------------
variable "tags" {
  description = "全DynamoDBテーブルに付与するタグ"
  type        = map(string)
  default     = {}
}
