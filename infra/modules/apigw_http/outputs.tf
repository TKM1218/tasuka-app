# --------------------------------------------------
# outputs: http api
# --------------------------------------------------
output "api_id" {
  description = "HTTP API ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "HTTP API endpoint"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "authorizer_id" {
  description = "JWT authorizer ID"
  value       = aws_apigatewayv2_authorizer.jwt.id
}

output "stage_name" {
  description = "HTTP API stage name"
  value       = aws_apigatewayv2_stage.default.name
}
