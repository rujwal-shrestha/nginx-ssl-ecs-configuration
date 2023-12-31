locals {
  region           = var.region
  name             = "kms--${replace(basename(path.cwd), "_", "-")}"
  current_identity = data.aws_caller_identity.current.arn

  tags = {
    Name    = local.name
    Example = "complete"
  }
}
