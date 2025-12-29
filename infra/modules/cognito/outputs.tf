# --------------------------------------------------
# outputs: user pool
# --------------------------------------------------
output "user_pool_id" {
  description = "Cognito User Pool ID。"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN。"
  value       = aws_cognito_user_pool.main.arn
}

# --------------------------------------------------
# outputs: user pool client
# --------------------------------------------------
output "user_pool_client_id" {
  description = "Cognito User Pool Client ID。"
  value       = aws_cognito_user_pool_client.web.id
}

# --------------------------------------------------
# outputs: hosted ui / issuer
# --------------------------------------------------
output "issuer" {
  description = "JWT検証に使うIssuer。"
  value       = "https://cognito-idp.${data.aws_region.current.id}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}

output "hosted_ui_domain" {
  description = "Cognito Hosted UIドメイン。"
  value       = "${aws_cognito_user_pool_domain.main.domain}.auth.${data.aws_region.current.id}.amazoncognito.com"
}
