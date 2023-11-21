# VPC
module "vpc" {
  count   = var.use_custom_vpc ? 0 : 1
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  name    = local.vpc.name
  cidr    = local.vpc.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] #TBC
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true # Should be true if you want to provision NAT Gateways for each of your private networks
}
