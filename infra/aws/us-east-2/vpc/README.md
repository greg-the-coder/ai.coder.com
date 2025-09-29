<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.46 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for created resources and as a tag prefix | `string` | n/a | yes |
| <a name="input_private_subnet_az1_cidr"></a> [private\_subnet\_az1\_cidr](#input\_private\_subnet\_az1\_cidr) | The private subnet for az1 | `string` | n/a | yes |
| <a name="input_private_subnet_az2_cidr"></a> [private\_subnet\_az2\_cidr](#input\_private\_subnet\_az2\_cidr) | The private subnet for az2 | `string` | n/a | yes |
| <a name="input_private_subnet_az3_cidr"></a> [private\_subnet\_az3\_cidr](#input\_private\_subnet\_az3\_cidr) | The private subnet for az3 | `string` | n/a | yes |
| <a name="input_public_subnet_az1_cidr"></a> [public\_subnet\_az1\_cidr](#input\_public\_subnet\_az1\_cidr) | The public subnet for az1 | `string` | n/a | yes |
| <a name="input_public_subnet_az2_cidr"></a> [public\_subnet\_az2\_cidr](#input\_public\_subnet\_az2\_cidr) | The public subnet for az2 | `string` | n/a | yes |
| <a name="input_public_subnet_az3_cidr"></a> [public\_subnet\_az3\_cidr](#input\_public\_subnet\_az3\_cidr) | The public subnet for az3 | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The aws region for the vpc | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The vpc cidr block | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The created private subnet ids |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The created public subnet ids |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The created vpc\_id |
<!-- END_TF_DOCS -->