<!-- BEGIN_TF_DOCS -->
## Introduction
This module creates ssh key file and stores the same in local machine.

## Resources

| Name | Type |
|------|------|
| [local_file.ssh_key_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_algorithm"></a> [algorithm](#input\_algorithm) | Type of algorithm used for key creation | `string` | `"RSA"` | no |
| <a name="input_file_name"></a> [file\_name](#input\_file\_name) | Name of file to store ssh\_key | `string` | `"ssh_key_file"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"ari-portal-dev-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags value assigned to resource | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_key_id"></a> [ssh\_key\_id](#output\_ssh\_key\_id) | ssh key id |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | ssh key content |
<!-- END_TF_DOCS -->