# -------------------------------
# variables: basic settings
# -------------------------------
variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

# AWS provider profile selection for local runs.
variable "aws_profile" {
  description = "AWS CLI profile name for the dev environment"
  type        = string
}

# -------------------------------
# variables: common tags
# -------------------------------
variable "tags" {
  description = "Common tags for all resources in this environment"
  type        = map(string)
  default     = {}
}

# -------------------------------
# variables: terraform state
# -------------------------------
variable "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state storage."
  type        = string
}

variable "tfstate_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}
