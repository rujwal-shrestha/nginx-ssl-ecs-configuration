
terraform {
  backend "s3" {
    bucket         = "terraform-module-state-files"
    region         = "us-east-1"
    key            = "nginx/terraform.tfstate"
    dynamodb_table = "terraform-module-state-files"
  }
}
