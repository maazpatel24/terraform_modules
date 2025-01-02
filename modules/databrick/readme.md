<!-- BEGIN_TF_DOCS -->
## Introduction

This Module creates azure Databrick.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.66 |

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.databrick_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"southeastasia"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | The name of the Azure Databricks workspace. | `list(string)` | <pre>[<br>  "databricks-workspace01",<br>  "databrick-workspace02"<br>]</pre> | no |
| <a name="input_workspace_sku"></a> [workspace\_sku](#input\_workspace\_sku) | The SKU name for the Databricks workspace. | `string` | `"standard"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The ID of the created Azure Databricks workspace. |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The URL of the created Azure Databricks workspace. |
<!-- END_TF_DOCS -->