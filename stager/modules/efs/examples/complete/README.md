<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | ../.. | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | github.com/ltd/terraform-aws-kms-module.git | 7577f08 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/ltd/terraform-aws-vpc-module.git | f15cfc1 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Name of the application | `string` | `""` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | n/a | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Working application environment eg: dev, stg, prd | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `""` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | n/a | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_points"></a> [access\_points](#output\_access\_points) | Map of access points created and their attributes |
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name of the file system |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name for the filesystem per [documented convention](http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html) |
| <a name="output_id"></a> [id](#output\_id) | The ID that identifies the file system (e.g., `fs-ccfc0d65`) |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | Map of mount targets created and their attributes |
| <a name="output_replication_configuration_destination_file_system_id"></a> [replication\_configuration\_destination\_file\_system\_id](#output\_replication\_configuration\_destination\_file\_system\_id) | The file system ID of the replica |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_size_in_bytes"></a> [size\_in\_bytes](#output\_size\_in\_bytes) | The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time |
<!-- END_TF_DOCS -->
