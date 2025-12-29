terraform {
  backend "s3" {
    bucket         = "tasuka-dev-tfstate-bucket-299030937743"
    key            = "tasuka/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tasuka-dev-terraform-locks"
    profile        = "tf-sso"
    encrypt        = true
  }
}
