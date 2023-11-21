locals {
  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
    ]

    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 32768
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]

    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      # {
      #   rule_number     = 140
      #   rule_action     = "allow"
      #   from_port       = 80
      #   to_port         = 80
      #   protocol        = "tcp"
      #   ipv6_cidr_block = "10.0.0.0/16"
      # },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1433
        to_port     = 1433
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      # {
      #   rule_number = 140
      #   rule_action = "allow"
      #   icmp_code   = -1
      #   icmp_type   = 8
      #   protocol    = "icmp"
      #   cidr_block  = "10.0.0.0/22"
      # },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/16"
      },
      # {
      #   rule_number     = 140
      #   rule_action     = "allow"
      #   from_port       = 80
      #   to_port         = 80
      #   protocol        = "tcp"
      #   ipv6_cidr_block = "10.0.0.0/16"
      # },
    ]
    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1433
        to_port     = 1433
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      # {
      #   rule_number = 140
      #   rule_action = "allow"
      #   icmp_code   = -1
      #   icmp_type   = 8
      #   protocol    = "icmp"
      #   cidr_block  = "10.0.0.0/22"
      # },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
  }
}

################################################################################
# Supporting resources
################################################################################
module "vpc" {
  source = "github.com/ltd/terraform-aws-vpc-module.git?ref=b7c3a76"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  #For creating dedicated  network ACL rules for public
  public_dedicated_network_acl = var.public_dedicated_network_acl
  public_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  public_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])

  #For creating dedicated  network ACL rules for private
  private_dedicated_network_acl = var.private_dedicated_network_acl
  private_inbound_acl_rules     = concat(local.network_acls["private_inbound"])
  private_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["private_outbound"])

  # Disabled NAT gateway to save a few seconds running this example
  enable_nat_gateway   = false
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source = "github.com/terraform-aws-modules/terraform-aws-acm?ref=27e32f5"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.id
}

# resource "aws_eip" "this" {
#   #checkov:skip=CKV2_AWS_19
#   count = length(local.azs)
#   # domain = "vpc"
# }

#tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-enable-versioning
module "s3_bucket_for_logs" {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=d371175"

  bucket = "terraform-aws-module-nlb-access-logs"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs
}
