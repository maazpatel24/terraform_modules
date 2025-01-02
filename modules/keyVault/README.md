<!-- BEGIN_TF_DOCS -->
## Introduction

This module creates Azure Key-Vault and Keys.

Key Vault can be used to Securely store and control access to tokens, passwords, certificates, API keys, and other secrets.


## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.kvkuser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.keyvault_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The name of the current environment. | `string` | `"dev"` | no |
| <a name="input_expire_after"></a> [expire\_after](#input\_expire\_after) | Expire a Key Vault Key after given duration as an ISO 8601 duration. | `string` | `"P90D"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the keyvault key. | `list(string)` | <pre>[<br>  "key01"<br>]</pre> | no |
| <a name="input_key_opts"></a> [key\_opts](#input\_key\_opts) | A list of JSON web key operations. | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| <a name="input_key_permissions"></a> [key\_permissions](#input\_key\_permissions) | List of key permissions. | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Update",<br>  "Create",<br>  "Import",<br>  "Delete",<br>  "Recover",<br>  "Backup",<br>  "Restore",<br>  "Decrypt",<br>  "Encrypt",<br>  "UnwrapKey",<br>  "WrapKey",<br>  "Verify",<br>  "Sign",<br>  "Purge"<br>]</pre> | no |
| <a name="input_key_size"></a> [key\_size](#input\_key\_size) | Specifies the Size of the RSA key to create in bytes. | `number` | `2048` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Specifies the Key Type to use for this Key Vault Key. | `string` | `"RSA"` | no |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | The name of the Key Vault. | `string` | `"keyVault01"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created. | `string` | `"eastus"` | no |
| <a name="input_notify_before_expiry"></a> [notify\_before\_expiry](#input\_notify\_before\_expiry) | Notify at a given duration before expiry as an ISO 8601 duration. | `string` | `"P30D"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources. | `string` | `"eic"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_secret_permissions"></a> [secret\_permissions](#input\_secret\_permissions) | List of secret permissions. | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Set",<br>  "Delete",<br>  "Recover",<br>  "Backup",<br>  "Restore",<br>  "Purge"<br>]</pre> | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The Name of the SKU used for this Key Vault. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. | `number` | `90` | no |
| <a name="input_storage_permissions"></a> [storage\_permissions](#input\_storage\_permissions) | List of storage permissions. | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Update"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed. | `map(string)` | n/a | yes |
| <a name="input_time_before_expiry"></a> [time\_before\_expiry](#input\_time\_before\_expiry) | Rotate automatically at a duration before expiry as an ISO 8601 duration. | `string` | `"P30D"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policy_id"></a> [access\_policy\_id](#output\_access\_policy\_id) | The ID of the Access Policy. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The ID of the Key. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | The name of the Key. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault. |
<!-- END_TF_DOCS -->