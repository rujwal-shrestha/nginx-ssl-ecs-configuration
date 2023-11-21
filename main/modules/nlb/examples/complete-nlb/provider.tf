##################################################################
# Provider defination
##################################################################
provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
      Application = var.application
    }
  }
}
