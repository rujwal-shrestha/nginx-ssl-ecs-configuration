# data "aws_availability_zones" "available" {}

locals {

  #prefix
  prefix = "${var.owner}-${var.environment}-${var.application}"

  cluster = {
    name = "${local.prefix}-cluster"
  }

  service = {
    name = "${local.prefix}-service"
  }

  vpc_cidr = data.terraform_remote_state.stager_resources.outputs.vpc_cidr[0]
  # azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  container = {
    name      = "${local.prefix}-container"
    tls_name  = "${local.prefix}-container_tls"
    test_name = "${local.prefix}-container_test"
    port      = 80
    tls_port  = 443
    test_port = 8848
    image_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/nginx-ssl-ecs:latest"
  }

  nlb = {
    prefix = "nginx"
    name   = "${local.prefix}-nlb"
    type   = "network"
  }

  efs = {
    name = "${local.prefix}-efs"
  }

  other_hosts = [
    {
      name      = "tomcat-host"
      service   = "tomcat-service"
      image_url = "tomcat:jre8-alpine"
      port      = 8080
    }
  ]

}
