<!-- BEGIN_TF_DOCS -->
## Introduction
This module creates storage account with optional resources like a container, file share, queue, and table based on the provided variables.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.file_share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | The Access Level configured for this Container. | `string` | `"private"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of container set as optional variable if user wants to create container they can pass the name of the container | `list(string)` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_file_share_name"></a> [file\_share\_name](#input\_file\_share\_name) | name of file share set as optional variable if user wants to create file share they can pass the name of the file share | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"ari"` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | Name of the queue set as optional variable if user wants to create queue they can pass the name of the queue | `list(string)` | `[]` | no |
| <a name="input_quota"></a> [quota](#input\_quota) | Maximum size of the share, in gigabytes | `number` | `50` | no |
| <a name="input_replication_type"></a> [replication\_type](#input\_replication\_type) | Type of replication to use for this storage account | `string` | `"LRS"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"ari-portal-dev-rg"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of storage account | `string` | `"teststorage01"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of table set as optional variable if user wants to create table they can pass the name of the table | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |
| <a name="input_tier"></a> [tier](#input\_tier) | tier value | `string` | `"Standard"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Id of the container |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Container name |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Storage Account Name |
<!-- END_TF_DOCS -->