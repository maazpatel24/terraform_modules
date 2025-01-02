<!-- BEGIN_TF_DOCS -->
## Introduction
This module is used to create a redis cache. The Azure Redis Cache is a high-performance caching service that provides in-memory data store for faster retrieval of data. It is based on the open-source implementation Redis cache.

## Resources

| Name | Type |
|------|------|
| [azurerm_redis_cache.rediscache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"ari"` | no |
| <a name="input_redis_cache_name"></a> [redis\_cache\_name](#input\_redis\_cache\_name) | Name of redis cache | `list(string)` | <pre>[<br>  "rediscache01",<br>  "rediscache02"<br>]</pre> | no |
| <a name="input_rediscache_capacity"></a> [rediscache\_capacity](#input\_rediscache\_capacity) | The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4 | `number` | `2` | no |
| <a name="input_rediscache_enable_non_ssl_port"></a> [rediscache\_enable\_non\_ssl\_port](#input\_rediscache\_enable\_non\_ssl\_port) | Enable the non-SSL port (6379) - disabled by default | `bool` | `false` | no |
| <a name="input_rediscache_family"></a> [rediscache\_family](#input\_rediscache\_family) | The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium) | `string` | `"C"` | no |
| <a name="input_rediscache_minimum_tls_version"></a> [rediscache\_minimum\_tls\_version](#input\_rediscache\_minimum\_tls\_version) | The minimum TLS version | `string` | `"1.2"` | no |
| <a name="input_rediscache_sku_name"></a> [rediscache\_sku\_name](#input\_rediscache\_sku\_name) | The SKU of Redis to use. Possible values are Basic, Standard and Premium | `string` | `"Standard"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"ari-portal-dev-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_client_name"></a> [redis\_client\_name](#output\_redis\_client\_name) | Redis cache Name |
| <a name="output_redis_client_password"></a> [redis\_client\_password](#output\_redis\_client\_password) | Redis cache access key |
<!-- END_TF_DOCS -->