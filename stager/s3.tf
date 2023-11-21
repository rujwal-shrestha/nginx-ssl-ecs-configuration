module "s3_bucket_for_server_configs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${local.prefix}-certificates-configs"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true
  versioning = {
    enabled = true
  }
}

module "notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "3.15.1"
  bucket  = module.s3_bucket_for_server_configs.s3_bucket_id

  eventbridge = true
  lambda_notifications = {
    lambda1 = {
      function_arn  = module.lambda_function.lambda_function_arn
      function_name = module.lambda_function.lambda_function_name
      events        = ["s3:ObjectCreated:Put"]
    }
  }
}
