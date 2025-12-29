# --------------------------------------------------
# cloudwatch logs: lambda api
# --------------------------------------------------
resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${var.name_prefix}-api"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# --------------------------------------------------
# lambda: api function
# --------------------------------------------------
resource "aws_lambda_function" "api" {
  function_name = "${var.name_prefix}-api"
  role          = var.lambda_role_arn
  runtime       = var.runtime
  handler       = "index.handler"

  filename         = var.artifact_type == "local" ? var.artifact_path : null
  source_code_hash = var.artifact_type == "local" ? filebase64sha256(var.artifact_path) : null

  s3_bucket         = var.artifact_type == "s3" ? var.s3_bucket : null
  s3_key            = var.artifact_type == "s3" ? var.s3_key : null
  s3_object_version = var.artifact_type == "s3" && var.s3_object_version != "" ? var.s3_object_version : null

  environment {
    variables = var.environment_variables
  }

  memory_size = var.memory_size
  timeout     = var.timeout
  tags        = var.tags

  lifecycle {
    precondition {
      # 値がlocal以外だったらOKだがlocalならartifact_pathの空欄は弾く
      condition     = var.artifact_type != "local" || length(var.artifact_path) > 0
      error_message = "artifact_type=local の場合は artifact_path を指定してください。"
    }
    precondition {
      # 値がs3以外だったらOKだがs3ならs3_bucketの空欄は弾く
      condition     = var.artifact_type != "s3" || length(var.s3_bucket) > 0
      error_message = "artifact_type=s3 の場合は s3_bucket を指定してください。"
    }
    precondition {
      # 値がs3以外だったらOKだがs3ならs3_keyの空欄は弾く
      condition     = var.artifact_type != "s3" || length(var.s3_key) > 0
      error_message = "artifact_type=s3 の場合は s3_key を指定してください。"
    }
  }

  # Log Groupを先に作って保持期間を固定させる
  depends_on = [aws_cloudwatch_log_group.api]
}
