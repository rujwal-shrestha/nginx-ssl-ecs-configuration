data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}
