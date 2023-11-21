################################################################################
# Defines the resources to be created
################################################################################

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
      Application = var.application
    }
  }

}
