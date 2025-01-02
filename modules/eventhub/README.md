<!-- BEGIN_TF_DOCS -->
## Introduction
This module ceates Eventhub.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_namespace.eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Define the throughput units | `number` | `1` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Specifies the name of the EventHub resource | `list(string)` | <pre>[<br>  "eic_eventhub_name01",<br>  "eic_eventhub_name02"<br>]</pre> | no |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | Specifies the name of the EventHub namespace resource | `string` | `"eiceventhubnamespace"` | no |
| <a name="input_eventhub_sku"></a> [eventhub\_sku](#input\_eventhub\_sku) | specify the pricing tier or SKU | `string` | `"Standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_message_retention"></a> [message\_retention](#input\_message\_retention) | Specifies the number of days to retain the events for this Event Hub | `string` | `1` | no |
| <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count) | Specifies the current number of shards on the Event Hub | `string` | `2` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"sa1"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"sa1_test_eic_AnjaliRajput"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_hub_namespace_id"></a> [event\_hub\_namespace\_id](#output\_event\_hub\_namespace\_id) | Eventhub namespace id |
| <a name="output_event_hub_namespace_name"></a> [event\_hub\_namespace\_name](#output\_event\_hub\_namespace\_name) | Eventhub namespace id |
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | Eventhub id |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | Eventhub name |
<!-- END_TF_DOCS -->