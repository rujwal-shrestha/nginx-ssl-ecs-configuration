locals {

  prefix = "${var.owner}-${var.environment}-${var.application}"

  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  efs = {
    name = "${local.prefix}-efs"
  }
  vpc = {
    name     = "${local.prefix}-vpc"
    vpc_cidr = "10.0.0.0/16"
  }

}
