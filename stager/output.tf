#S3
output "s3_id" {
  description = "The ID of S3 Bucket that stores certifcates and server configs"
  value       = module.s3_bucket_for_server_configs.s3_bucket_id

}

#EFS
output "efs_id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
  value       = module.efs.id
}

output "efs_access_point_id" {
  value = module.efs.access_point_id["root_example"]
}

# VPC
output "private_subnets" {
  description = "The ID of the private subnet"
  value       = var.use_custom_vpc ? var.private_subnets : module.vpc[0].private_subnets
}

output "public_subnets" {
  description = "The ID of the public subnet"
  value       = var.use_custom_vpc ? var.public_subnets : module.vpc[0].public_subnets
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.use_custom_vpc ? var.vpc_id : module.vpc[0].vpc_id
}

output "vpc_cidr" {
  description = "CIDR Block of VPC"
  value       = var.use_custom_vpc ? [data.aws_vpc.selected.cidr_block] : [local.vpc.vpc_cidr]
}
