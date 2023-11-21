
data "aws_availability_zones" "available" {}


##################################################################
# Network Load Balancer
##################################################################

module "nlb" {
  source = "../../"

  name = local.name

  load_balancer_type         = "network"
  vpc_id                     = module.vpc.vpc_id
  enable_deletion_protection = var.enable_deletion_protection
  create_security_group      = false

  # Use `subnets` if you don't want to attach EIPs
  subnets = module.vpc.private_subnets

  # Use `subnet_mapping` to attach EIPs
  # subnet_mapping = [for i, eip in aws_eip.this : { allocation_id : eip.id, subnet_id : module.vpc.private_subnets[i] }]

  # # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  access_logs = {
    enabled = true
    prefix  = "test-nlb"
    bucket  = module.s3_bucket_for_logs.s3_bucket_id
  }

  # TCP_UDP, UDP, TCP
  http_tcp_listeners = [
    {
      port               = 81
      protocol           = "TCP_UDP"
      target_group_index = 0
    },
    {
      port               = 82
      protocol           = "UDP"
      target_group_index = 1
    },
    {
      port               = 83
      protocol           = "TCP"
      target_group_index = 2
    },
  ]

  #  TLS
  https_listeners = [
    {
      port               = 84
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 3
    },
  ]

  target_groups = [
    {
      name_prefix            = "tu1-"
      backend_protocol       = "TCP_UDP"
      backend_port           = 81
      target_type            = "instance"
      connection_termination = true
      preserve_client_ip     = true
      stickiness = {
        enabled = true
        type    = "source_ip"
      }
      tags = {
        tcp_udp = true
      }
    },
    {
      name_prefix      = "u1-"
      backend_protocol = "UDP"
      backend_port     = 82
      target_type      = "instance"
    },
    {
      name_prefix          = "t1-"
      backend_protocol     = "TCP"
      backend_port         = 83
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
    {
      name_prefix      = "t2-"
      backend_protocol = "TLS"
      backend_port     = 84
      target_type      = "instance"
    },
  ]

  tags = merge(local.tags, {
    attributes = join(",", var.attributes)

  })
}
