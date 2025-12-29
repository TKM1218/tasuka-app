# --------------------------------------
# terraform state: S3 backend storage
# --------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_bucket_name
  tags   = var.tags
}

# --------------------------------------
# terraform state: DynamoDB state lock
# --------------------------------------
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
