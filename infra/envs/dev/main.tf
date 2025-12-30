# --------------------------------------------------
# terraform state: S3 backend storage
# --------------------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_bucket_name
  tags   = var.tags
}

# --------------------------------------------------
# terraform state: DynamoDB state lock
# --------------------------------------------------
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = var.tfstate_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

# --------------------------------------------------
# application data: DynamoDB tables
# --------------------------------------------------
module "dynamodb" {
  source      = "../../modules/dynamodb"
  name_prefix = local.name_prefix
  tags        = var.tags
}

# --------------------------------------------------
# iam: lambda execution role and policy
# --------------------------------------------------
module "iam" {
  source      = "../../modules/iam"
  name_prefix = local.name_prefix
  dynamodb_table_arns = [
    module.dynamodb.lists_table_arn,
    module.dynamodb.list_members_table_arn,
    module.dynamodb.items_table_arn,
    module.dynamodb.notifications_table_arn,
  ]
  # SSM ParameterのARNはSSMモジュール導入後に配線する想定
  ssm_param_arns = []
  tags           = var.tags
}

# --------------------------------------------------
# authentication: Cognito user pool
# --------------------------------------------------
module "cognito" {
  source                  = "../../modules/cognito"
  name_prefix             = local.name_prefix
  hosted_ui_domain_prefix = var.cognito_hosted_ui_domain_prefix
  callback_urls           = var.cognito_callback_urls
  logout_urls             = var.cognito_logout_urls
  tags                    = var.tags
}

# --------------------------------------------------
# lambda: api
# --------------------------------------------------
module "lambda_api" {
  source          = "../../modules/lambda_api"
  name_prefix     = local.name_prefix
  lambda_role_arn = module.iam.lambda_role_arn

  artifact_path = "${path.root}/../../../artifacts/lambda-api/dummy-lambda-api.zip"

  environment_variables = {
    LISTS_TABLE         = module.dynamodb.lists_table_name
    LIST_MEMBERS_TABLE  = module.dynamodb.list_members_table_name
    ITEMS_TABLE         = module.dynamodb.items_table_name
    NOTIFICATIONS_TABLE = module.dynamodb.notifications_table_name
  }

  tags                  = var.tags
}

# --------------------------------------------------
# api gateway: http api
# --------------------------------------------------
module "apigw_http" {
  source               = "../../modules/apigw_http"
  name_prefix          = local.name_prefix
  lambda_invoke_arn    = module.lambda_api.invoke_arn
  lambda_function_name = module.lambda_api.function_name
  jwt_issuer           = module.cognito.issuer
  jwt_audience         = [module.cognito.user_pool_client_id]
  cors_allow_origins = distinct([
    for url in concat(var.cognito_callback_urls, var.cognito_logout_urls) : regex("^https?://[^/]+", url)
  ])
  tags = var.tags
}

# --------------------------------------------------
# scheduler: base schedule (temporary wiring)
# --------------------------------------------------
module "scheduler" {
  source               = "../../modules/scheduler"
  name_prefix          = local.name_prefix
  schedule_expression  = var.scheduler_schedule_expression
  target_lambda_arn    = module.lambda_api.function_arn
  target_input         = var.scheduler_target_input
  tags                 = var.tags
}
