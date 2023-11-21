resource "aws_security_group" "lambda_security_group" {
  name        = "${local.prefix}-lambda-sg"
  description = "Security group for NFS traffic"
  vpc_id      = var.use_custom_vpc ? var.vpc_id : module.vpc[0].vpc_id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.use_custom_vpc ? [data.aws_vpc.selected.cidr_block] : [local.vpc.vpc_cidr] # You might want to restrict this to specific IPs or ranges
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # You might want to restrict this to specific IPs or ranges
  }
}


module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.2.0"

  function_name = "${local.prefix}-lambda"
  description   = "For downloading files from s3 and uploading to efs"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  source_path = "./lambda_function.py"

  vpc_subnet_ids         = var.use_custom_vpc ? var.private_subnets : module.vpc[0].private_subnets
  vpc_security_group_ids = [aws_security_group.lambda_security_group.id]
  attach_policy_json     = true
  policy_json            = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3-object-lambda:*"
            ],
            "Resource": [
                "${module.s3_bucket_for_server_configs.s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
  #TBC
  file_system_arn              = module.efs.access_point_arn["root_example"]
  file_system_local_mount_path = "/mnt/efs"
  attach_network_policy        = true
  depends_on                   = [module.efs]
}
