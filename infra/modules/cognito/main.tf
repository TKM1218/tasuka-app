# --------------------------------------------------
# data: region
# --------------------------------------------------
data "aws_region" "current" {}

# --------------------------------------------------
# cognito: user pool
# --------------------------------------------------
# Web/モバイル向けの基本認証基盤を構築する。
resource "aws_cognito_user_pool" "main" {
  name = "${var.name_prefix}-user-pool"

  # メールアドレスをユーザー名として扱い、検証も行う。
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Hosted UIでの自己サインアップを許可
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # 最低限の強いパスワードポリシーを設定。
  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  tags = var.tags
}

# --------------------------------------------------
# cognito: user pool client (web)
# --------------------------------------------------
# Hosted UI / OAuth code flow 前提のクライアント設定。
resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.name_prefix}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = var.oauth_scopes
  supported_identity_providers         = ["COGNITO"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # 不要なユーザー存在情報の漏えいを防ぐ。
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

# --------------------------------------------------
# cognito: hosted ui domain
# --------------------------------------------------
# Cognitoの標準Hosted UIドメインを払い出す。
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.hosted_ui_domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}
