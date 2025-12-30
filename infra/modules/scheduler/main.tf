# --------------------------------------------------
# locals: target input handling
# --------------------------------------------------
locals {
  # JSON文字列はそのまま、mapなどはjsonencodeで変換
  target_input = var.target_input == null ? null : (
    can(jsondecode(var.target_input)) ? var.target_input : jsonencode(var.target_input)
  )
}

# --------------------------------------------------
# iam: scheduler invoke role
# --------------------------------------------------
resource "aws_iam_role" "scheduler" {
  name = "${var.name_prefix}-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "invoke_lambda" {
  name = "${var.name_prefix}-scheduler-invoke"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["lambda:InvokeFunction"],
        Resource = var.target_lambda_arn
      }
    ]
  })
}

# --------------------------------------------------
# scheduler: eventbridge schedule
# --------------------------------------------------
resource "aws_scheduler_schedule" "main" {
  name                         = "${var.name_prefix}-schedule"
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"  # OFFなら指定時刻通りに実行、FLEXIBLEなら実行遅れを許容
  }

  target {
    arn      = var.target_lambda_arn
    role_arn = aws_iam_role.scheduler.arn
    input    = local.target_input
  }

  # tags = var.tags  # なぜかエラーになるので一旦コメントアウト（エラー文：An argument named "tags" is not expected here.）
}
