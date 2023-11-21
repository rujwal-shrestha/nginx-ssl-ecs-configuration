
locals {
  region   = "us-east-1"
  name     = "adex-efs-${replace(basename(path.cwd), "_", "-")}"
  vpc_cidr = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-efs"
  }
}
