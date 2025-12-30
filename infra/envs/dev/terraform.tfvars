# --------------------------------------------------
# variables: basic settings
# --------------------------------------------------
project     = "tasuka"
env         = "dev"
aws_profile = "tf-sso"

# --------------------------------------------------
# variables: common tags
# --------------------------------------------------
tags = {
  project = "tasuka"
  env     = "dev"
}

# --------------------------------------------------
# variables: cognito (dev dummy)
# --------------------------------------------------
cognito_hosted_ui_domain_prefix = "tasuka-dev-12345"
cognito_callback_urls = [
  "http://localhost:3000/auth/callback",
]
cognito_logout_urls = [
  "http://localhost:3000/",
]

# --------------------------------------------------
# variables: scheduler
# --------------------------------------------------
scheduler_schedule_expression = "rate(7 days)"
scheduler_target_input        = null

# --------------------------------------------------
# variables: terraform state
# --------------------------------------------------
tfstate_bucket_name     = "tasuka-dev-tfstate-bucket-299030937743"
tfstate_lock_table_name = "tasuka-dev-terraform-locks"
