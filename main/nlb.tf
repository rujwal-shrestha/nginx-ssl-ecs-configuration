
module "nlb" {
  source = "./modules/nlb"

  name               = local.nlb.name
  load_balancer_type = local.nlb.type
  internal           = false

  vpc_id                     = data.terraform_remote_state.stager_resources.outputs.vpc_id
  subnets                    = data.terraform_remote_state.stager_resources.outputs.public_subnets
  create_security_group      = true
  enable_deletion_protection = var.enable_deletion_protection

  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  access_logs = {
    enabled = true
    prefix  = local.prefix
    bucket  = module.s3_bucket_for_logs.s3_bucket_id
  }

  # TCP_UDP, UDP, TCP
  http_tcp_listeners = [
    {
      port               = local.container.tls_port
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = local.container.port
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = local.container.test_port
      protocol           = "TCP"
      target_group_index = 3
    },

    # For request to other ports, we forward the request directly to the application without SSL Validation
    {
      port               = 8080
      protocol           = "TCP"
      target_group_index = 2
    },
  ]

  target_groups = [
    {
      name_prefix      = "tls-tg"
      backend_protocol = "TCP"
      backend_port     = local.container.tls_port
      target_type      = "ip",
      health_check = {
        enabled             = true
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        port                = local.container.tls_port
        protocol            = "TCP"
      }
    },

    {
      name_prefix      = "80-tg"
      backend_protocol = "TCP"
      backend_port     = local.container.port
      target_type      = "ip",
      health_check = {
        enabled             = true
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        port                = local.container.port
        protocol            = "TCP"
      }
    },
    {
      name_prefix      = local.nlb.prefix
      backend_protocol = "TCP"
      backend_port     = local.other_hosts[0].port
      target_type      = "ip",
      health_check = {
        enabled             = true
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        port                = local.other_hosts[0].port
        protocol            = "TCP"
      }
    },
    {
      name_prefix      = "test"
      backend_protocol = "TCP"
      backend_port     = local.container.test_port
      target_type      = "ip",
      health_check = {
        enabled             = true
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        port                = local.container.test_port
        protocol            = "TCP"
      }
    }
  ]
}

################################################################################
# Supporting Resources for NLB
################################################################################


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
