<!-- BEGIN_TF_DOCS -->
## Introduction
This module creates virtual network and subnets.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.publicsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_net_range"></a> [net\_range](#input\_net\_range) | Virtual network range | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"eic"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Subnet names | `list(string)` | <pre>[<br>  "subnet1",<br>  "subnet2",<br>  "subnet3"<br>]</pre> | no |
| <a name="input_subnet_range"></a> [subnet\_range](#input\_subnet\_range) | Subnet range for application gateway | `list(string)` | <pre>[<br>  "10.0.10.0/24",<br>  "10.0.20.0/24",<br>  "10.0.30.0/24"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of vnet | `string` | `"vnet1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet id |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Subnet name |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Virtual network ID |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Virtual network name |
<!-- END_TF_DOCS -->