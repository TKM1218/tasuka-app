# --------------------------------------------------
# cloudwatch logs: notify due
# --------------------------------------------------
resource "aws_cloudwatch_log_group" "notify_due" {
  name              = "/aws/lambda/${var.name_prefix}-notify-due"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# --------------------------------------------------
# cloudwatch logs: notify weather
# --------------------------------------------------
resource "aws_cloudwatch_log_group" "notify_weather" {
  name              = "/aws/lambda/${var.name_prefix}-notify-weather"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# --------------------------------------------------
# lambda: notify due
# --------------------------------------------------
resource "aws_lambda_function" "notify_due" {
  function_name = "${var.name_prefix}-notify-due"
  role          = var.lambda_role_arn
  runtime       = var.runtime
  handler       = "index.handler"

  filename         = var.artifact_path_due
  source_code_hash = filebase64sha256(var.artifact_path_due)

  environment {
    variables = var.due_environment_variables
  }

  memory_size = var.memory_size
  timeout     = var.timeout
  tags        = var.tags

  depends_on = [aws_cloudwatch_log_group.notify_due]
}

# --------------------------------------------------
# lambda: notify weather
# --------------------------------------------------
resource "aws_lambda_function" "notify_weather" {
  function_name = "${var.name_prefix}-notify-weather"
  role          = var.lambda_role_arn
  runtime       = var.runtime
  handler       = "index.handler"

  filename         = var.artifact_path_weather
  source_code_hash = filebase64sha256(var.artifact_path_weather)

  environment {
    variables = var.weather_environment_variables
  }

  memory_size = var.memory_size
  timeout     = var.timeout
  tags        = var.tags

  depends_on = [aws_cloudwatch_log_group.notify_weather]
}
