# --------------------------------------------------
# api gateway: http api
# --------------------------------------------------
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.name_prefix}-http"
  protocol_type = "HTTP"

  # Next.js (Vercel) からの呼び出しを想定したCORS
  cors_configuration {
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = var.cors_allow_origins
    allow_credentials = var.cors_allow_credentials
    max_age           = var.cors_max_age
    expose_headers    = var.cors_expose_headers
  }

  tags = var.tags
}

# --------------------------------------------------
# authorizer: cognito jwt
# --------------------------------------------------
resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id          = aws_apigatewayv2_api.main.id
  name            = "${var.name_prefix}-jwt"
  authorizer_type = "JWT"
  identity_sources = [
    "$request.header.Authorization",
  ]

  jwt_configuration {
    issuer   = var.jwt_issuer
    audience = var.jwt_audience
  }
}

# --------------------------------------------------
# integration: lambda proxy
# --------------------------------------------------
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = var.integration_timeout_milliseconds
}

# --------------------------------------------------
# routes: mvp health check
# --------------------------------------------------
resource "aws_apigatewayv2_route" "health" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /health"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

# --------------------------------------------------
# routes: lists
# --------------------------------------------------
resource "aws_apigatewayv2_route" "lists_get" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /lists"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

resource "aws_apigatewayv2_route" "lists_post" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /lists"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

# --------------------------------------------------
# routes: list items
# --------------------------------------------------
resource "aws_apigatewayv2_route" "items_get" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /lists/{listId}/items"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

resource "aws_apigatewayv2_route" "items_post" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /lists/{listId}/items"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

# --------------------------------------------------
# stage: default
# --------------------------------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.stage_name
  auto_deploy = true
  tags        = var.tags
}

# --------------------------------------------------
# permission: api gateway -> lambda invoke
# --------------------------------------------------
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
