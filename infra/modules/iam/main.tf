# --------------------------------------------------
# locals: resource expansions
# --------------------------------------------------
locals {
  dynamodb_resources = concat(
    var.dynamodb_table_arns,
    [for arn in var.dynamodb_table_arns : "${arn}/index/*"]
  )
}

# --------------------------------------------------
# iam: assume role for lambda
# --------------------------------------------------
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --------------------------------------------------
# iam: lambda execution role
# --------------------------------------------------
resource "aws_iam_role" "lambda" {
  name               = "${var.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

# --------------------------------------------------
# iam: minimal permissions for lambda
# --------------------------------------------------
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "DynamoDBAccess"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable",
    ]
    resources = local.dynamodb_resources
  }

  # SSM/SecretsはARNが渡されたときだけ付与する
  dynamic "statement" {
    for_each = length(var.ssm_param_arns) > 0 ? [1] : []
    content {
      sid = "SSMParameterRead"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
      ]
      resources = var.ssm_param_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.secretsmanager_arns) > 0 ? [1] : []
    content {
      sid       = "SecretsManagerRead"
      actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      resources = var.secretsmanager_arns
    }
  }

  statement {
    sid = "CloudWatchLogsWrite"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "${var.name_prefix}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
