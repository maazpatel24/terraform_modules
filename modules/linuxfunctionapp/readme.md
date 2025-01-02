<!-- BEGIN_TF_DOCS -->
## Introduction 
This module creates linux function app.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.17 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.linux_function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_service_plan.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_linux_function_app_account_replication_type"></a> [linux\_function\_app\_account\_replication\_type](#input\_linux\_function\_app\_account\_replication\_type) | n/a | `string` | `"LRS"` | no |
| <a name="input_linux_function_app_account_tier"></a> [linux\_function\_app\_account\_tier](#input\_linux\_function\_app\_account\_tier) | n/a | `string` | `"Standard"` | no |
| <a name="input_linux_function_app_function"></a> [linux\_function\_app\_function](#input\_linux\_function\_app\_function) | Function of the resource | `string` | `"wb"` | no |
| <a name="input_linux_function_app_lifecycle"></a> [linux\_function\_app\_lifecycle](#input\_linux\_function\_app\_lifecycle) | Lifecycle of resource according to environment | `string` | `"d"` | no |
| <a name="input_linux_function_app_network_region"></a> [linux\_function\_app\_network\_region](#input\_linux\_function\_app\_network\_region) | Value for region | `string` | `"sa1"` | no |
| <a name="input_linux_function_app_object"></a> [linux\_function\_app\_object](#input\_linux\_function\_app\_object) | Value of object type of the resource creating | `list(string)` | <pre>[<br>  "salinux",<br>  "lsp",<br>  "lfa"<br>]</pre> | no |
| <a name="input_linux_function_app_os_type"></a> [linux\_function\_app\_os\_type](#input\_linux\_function\_app\_os\_type) | Name of Operating system | `string` | `"Linux"` | no |
| <a name="input_linux_function_app_service"></a> [linux\_function\_app\_service](#input\_linux\_function\_app\_service) | Service name | `string` | `"ma"` | no |
| <a name="input_linux_function_app_sku_name"></a> [linux\_function\_app\_sku\_name](#input\_linux\_function\_app\_sku\_name) | Type of sku | `string` | `"Y1"` | no |
| <a name="input_linux_functionapp_always_on"></a> [linux\_functionapp\_always\_on](#input\_linux\_functionapp\_always\_on) | The URL of the API definition that describes this Windows Function App. | `bool` | `false` | no |
| <a name="input_linux_functionapp_ftps_state"></a> [linux\_functionapp\_ftps\_state](#input\_linux\_functionapp\_ftps\_state) | State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled | `string` | `"Disabled"` | no |
| <a name="input_linux_functionapp_http2_enabled"></a> [linux\_functionapp\_http2\_enabled](#input\_linux\_functionapp\_http2\_enabled) | Specifies if the HTTP2 protocol should be enabled. | `bool` | `false` | no |
| <a name="input_linux_functionapp_load_balancing_mode"></a> [linux\_functionapp\_load\_balancing\_mode](#input\_linux\_functionapp\_load\_balancing\_mode) | The Site load balancing mode. | `string` | `"LeastRequests"` | no |
| <a name="input_linux_functionapp_managed_pipeline_mode"></a> [linux\_functionapp\_managed\_pipeline\_mode](#input\_linux\_functionapp\_managed\_pipeline\_mode) | Managed pipeline mode. | `string` | `"Integrated"` | no |
| <a name="input_linux_functionapp_minimum_tls_version"></a> [linux\_functionapp\_minimum\_tls\_version](#input\_linux\_functionapp\_minimum\_tls\_version) | Configures the minimum version of TLS required for SSL requests. | `string` | `"1.2"` | no |
| <a name="input_linux_functionapp_name"></a> [linux\_functionapp\_name](#input\_linux\_functionapp\_name) | Name of functionapp | `list(string)` | <pre>[<br>  "linuxfunctionapp"<br>]</pre> | no |
| <a name="input_linux_functionapp_remote_debugging_enabled"></a> [linux\_functionapp\_remote\_debugging\_enabled](#input\_linux\_functionapp\_remote\_debugging\_enabled) | Should Remote Debugging be enabled. | `bool` | `true` | no |
| <a name="input_linux_functionapp_remote_debugging_version"></a> [linux\_functionapp\_remote\_debugging\_version](#input\_linux\_functionapp\_remote\_debugging\_version) | The Remote Debugging Version. | `string` | `"VS2019"` | no |
| <a name="input_linux_functionapp_runtime_scale_monitoring_enabled"></a> [linux\_functionapp\_runtime\_scale\_monitoring\_enabled](#input\_linux\_functionapp\_runtime\_scale\_monitoring\_enabled) | Should Scale Monitoring of the Functions Runtime be enabled? | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"southeastasia"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"default_rg"` | no |
| <a name="input_service_plan_name"></a> [service\_plan\_name](#input\_service\_plan\_name) | Name of service plan | `list(string)` | <pre>[<br>  "linux_service_plan01"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linux_function_app_id"></a> [linux\_function\_app\_id](#output\_linux\_function\_app\_id) | Id of linux function app |
| <a name="output_linux_function_app_name"></a> [linux\_function\_app\_name](#output\_linux\_function\_app\_name) | Name of linux function app |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | Id of service plan |
| <a name="output_storage_account_access_key"></a> [storage\_account\_access\_key](#output\_storage\_account\_access\_key) | Access key of storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of storage accout |
<!-- END_TF_DOCS -->