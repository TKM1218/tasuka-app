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
