<!-- BEGIN_TF_DOCS -->
## Introduction
This module creates iot hub.

## Resources

| Name | Type |
|------|------|
| [azurerm_iothub.iothub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Define the throughput units | `number` | `1` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_iothub_name"></a> [iothub\_name](#input\_iothub\_name) | Name of iothub | `list(string)` | <pre>[<br>  "eiciothub"<br>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"eic"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | specify the pricing tier or SKU | `string` | `"B1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iothub_id"></a> [iothub\_id](#output\_iothub\_id) | IOT hub id |
| <a name="output_iothub_name"></a> [iothub\_name](#output\_iothub\_name) | IOT hub name |
<!-- END_TF_DOCS -->