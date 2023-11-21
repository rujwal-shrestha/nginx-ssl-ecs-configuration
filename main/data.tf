data "aws_caller_identity" "current" {}

data "terraform_remote_state" "stager_resources" {
  backend = "s3"
  config = {
    bucket  = "terraform-module-state-files"
    region  = "us-east-1"
    encrypt = true
    key     = "nginx-workflow/terraform.tfstate"
  }
}
