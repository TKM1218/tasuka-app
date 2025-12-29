# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
variable "name_prefix" {
  description = "Cognitoリソース名のプレフィックス"
  type        = string
}

variable "hosted_ui_domain_prefix" {
  description = "Cognito Hosted UIのドメインプレフィックス（グローバルで一意）"
  type        = string
}

variable "callback_urls" {
  description = "OAuth callback URLの一覧"
  type        = list(string)
}

variable "logout_urls" {
  description = "OAuth logout URLの一覧"
  type        = list(string)
}

# --------------------------------------------------
# variables: oauth scopes
# --------------------------------------------------
variable "oauth_scopes" {
  description = "OAuthで許可するスコープ"
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

# --------------------------------------------------
# variables: common tags
# --------------------------------------------------
variable "tags" {
  description = "Cognito User Poolに付与するタグ"
  type        = map(string)
  default     = {}
}
