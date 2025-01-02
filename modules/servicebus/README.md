<!-- BEGIN_TF_DOCS -->
## Introduction

This module creates ServiceBus Queue with Namespace and Authorization rule on Azure environment.

Azure Service Bus is a messaging service on cloud used to connect any applications, devices, and services running in the cloud to any other applications or services. As a result, it acts as a messaging backbone for applications available in the cloud or across any devices.


## Resources

| Name | Type |
|------|------|
| [azurerm_servicebus_namespace.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_queue.servicebusqueue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dead_lettering_on_message_expiration"></a> [dead\_lettering\_on\_message\_expiration](#input\_dead\_lettering\_on\_message\_expiration) | Boolean flag which controls whether the Queue has dead letter support when a message expires | `bool` | `false` | no |
| <a name="input_default_message_ttl"></a> [default\_message\_ttl](#input\_default\_message\_ttl) | The ISO 8601 timespan duration of the TTL of messages sent to this queue | `string` | `"P14D"` | no |
| <a name="input_enable_partitioning"></a> [enable\_partitioning](#input\_enable\_partitioning) | Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_lock_duration"></a> [lock\_duration](#input\_lock\_duration) | The ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers | `string` | `"PT30S"` | no |
| <a name="input_max_delivery_count"></a> [max\_delivery\_count](#input\_max\_delivery\_count) | Integer value which controls when a message is automatically dead lettered. | `number` | `10` | no |
| <a name="input_max_size_in_megabytes"></a> [max\_size\_in\_megabytes](#input\_max\_size\_in\_megabytes) | Integer value which controls the size of memory allocated for the queue. | `number` | `1024` | no |
| <a name="input_policy_listen"></a> [policy\_listen](#input\_policy\_listen) | Grants listen access to this this Authorization Rule. | `bool` | `true` | no |
| <a name="input_policy_manage"></a> [policy\_manage](#input\_policy\_manage) | Grants manage access to this this Authorization Rule. | `bool` | `false` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Service bus policy name | `list(string)` | <pre>[<br>  "SendPolicy",<br>  "listenpolicy"<br>]</pre> | no |
| <a name="input_policy_send"></a> [policy\_send](#input\_policy\_send) | Grants send access to this this Authorization Rule. | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"eic"` | no |
| <a name="input_requires_duplicate_detection"></a> [requires\_duplicate\_detection](#input\_requires\_duplicate\_detection) | Boolean flag which controls whether the Queue requires duplicate detection | `bool` | `false` | no |
| <a name="input_requires_session"></a> [requires\_session](#input\_requires\_session) | Boolean flag which controls whether the Queue requires sessions | `bool` | `false` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_servicebus_namespace"></a> [servicebus\_namespace](#input\_servicebus\_namespace) | value | `string` | `"serviceBusNS"` | no |
| <a name="input_servicebusqueue_name"></a> [servicebusqueue\_name](#input\_servicebusqueue\_name) | Service bus queue name | `list(string)` | <pre>[<br>  "servicebusqueuerequest",<br>  "servicebusqueueresponse"<br>]</pre> | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Defines which tier to use. | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_servicebus_authorization_rule_id"></a> [servicebus\_authorization\_rule\_id](#output\_servicebus\_authorization\_rule\_id) | ID of the Authorization rule |
| <a name="output_servicebus_namespace_id"></a> [servicebus\_namespace\_id](#output\_servicebus\_namespace\_id) | Namespace ID of Service Bus |
| <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name) | Namespace name of Service Bus |
| <a name="output_servicebus_queue_id"></a> [servicebus\_queue\_id](#output\_servicebus\_queue\_id) | ID of Service Bus Queue |
| <a name="output_servicebus_queue_name"></a> [servicebus\_queue\_name](#output\_servicebus\_queue\_name) | Name of the Service Bus Queue |
<!-- END_TF_DOCS -->