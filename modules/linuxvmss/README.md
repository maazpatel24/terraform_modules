<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.linuxvmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_monitor_autoscale_setting.autoscale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Specifies the name of the local administrator account | `string` | `"eic"` | no |
| <a name="input_appgateway_backend_address_pool_id"></a> [appgateway\_backend\_address\_pool\_id](#input\_appgateway\_backend\_address\_pool\_id) | application gateway backend address pool id | `any` | n/a | yes |
| <a name="input_decrease_metric_name"></a> [decrease\_metric\_name](#input\_decrease\_metric\_name) | The name of the metric that defines what the rule monitors for scale down | `string` | `"Percentage CPU"` | no |
| <a name="input_decrease_operator"></a> [decrease\_operator](#input\_decrease\_operator) | Specifies the operator used to compare the metric data and threshold for scale down | `string` | `"LessThan"` | no |
| <a name="input_decrease_statistic"></a> [decrease\_statistic](#input\_decrease\_statistic) | Specifies how the metrics from multiple instances are combined for scale down | `string` | `"Average"` | no |
| <a name="input_decrease_threshold"></a> [decrease\_threshold](#input\_decrease\_threshold) | Specifies the threshold of the metric that triggers the scale action for scale down | `number` | `20` | no |
| <a name="input_decrease_time_aggregation"></a> [decrease\_time\_aggregation](#input\_decrease\_time\_aggregation) | Specifies how the data that's collected should be combined over time for scale down | `string` | `"Average"` | no |
| <a name="input_decrease_time_grain"></a> [decrease\_time\_grain](#input\_decrease\_time\_grain) | Specifies the granularity of metrics that the rule monitors, which must be one of the pre-defined values returned from the metric definitions for the metric for scale down | `string` | `"PT1M"` | no |
| <a name="input_decrease_time_window"></a> [decrease\_time\_window](#input\_decrease\_time\_window) | Specifies the time range for which data is collected, which must be greater than the delay in metric collection for scale down | `string` | `"PT5M"` | no |
| <a name="input_delete_os_disk_on_termination"></a> [delete\_os\_disk\_on\_termination](#input\_delete\_os\_disk\_on\_termination) | Delete datadisk when machine is terminated | `string` | `"false"` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_increase_metric_name"></a> [increase\_metric\_name](#input\_increase\_metric\_name) | The name of the metric that defines what the rule monitors for scale up | `string` | `"Percentage CPU"` | no |
| <a name="input_increase_operator"></a> [increase\_operator](#input\_increase\_operator) | Specifies the operator used to compare the metric data and threshold for scale up | `string` | `"GreaterThan"` | no |
| <a name="input_increase_statistic"></a> [increase\_statistic](#input\_increase\_statistic) | Specifies how the metrics from multiple instances are combined for scale up | `string` | `"Average"` | no |
| <a name="input_increase_threshold"></a> [increase\_threshold](#input\_increase\_threshold) | Specifies the threshold of the metric that triggers the scale action for scale up | `number` | `80` | no |
| <a name="input_increase_time_aggregation"></a> [increase\_time\_aggregation](#input\_increase\_time\_aggregation) | Specifies how the data that's collected should be combined over time for scale up | `string` | `"Average"` | no |
| <a name="input_increase_time_grain"></a> [increase\_time\_grain](#input\_increase\_time\_grain) | Specifies the granularity of metrics that the rule monitors, which must be one of the pre-defined values returned from the metric definitions for the metric for scale up | `string` | `"PT1M"` | no |
| <a name="input_increase_time_window"></a> [increase\_time\_window](#input\_increase\_time\_window) | Specifies the time range for which data is collected, which must be greater than the delay in metric collection for scale up | `string` | `"PT5M"` | no |
| <a name="input_instances_count"></a> [instances\_count](#input\_instances\_count) | The number of Virtual Machines in the Scale Set. | `number` | `2` | no |
| <a name="input_linux_subnet_id"></a> [linux\_subnet\_id](#input\_linux\_subnet\_id) | Drupal Subnet ID to create drupal VMSS | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_maximum_instances_count"></a> [maximum\_instances\_count](#input\_maximum\_instances\_count) | The maximum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `4` | no |
| <a name="input_minimum_instances_count"></a> [minimum\_instances\_count](#input\_minimum\_instances\_count) | The minimum number of instances for this resource. Valid values are between 0 and 1000 | `number` | `2` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | The Type of Storage Account which should back this the Internal OS Disk | `string` | `"Standard_LRS"` | no |
| <a name="input_os_upgrade_mode"></a> [os\_upgrade\_mode](#input\_os\_upgrade\_mode) | Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Automatic | `string` | `"Automatic"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"ari"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Public key for vmss instances | `string` | n/a | yes |
| <a name="input_publicip"></a> [publicip](#input\_publicip) | public ip name | `string` | `"publicip01"` | no |
| <a name="input_publisher"></a> [publisher](#input\_publisher) | Name of the publisher | `string` | `"Canonical"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"ari-portal-dev-rg"` | no |
| <a name="input_scaling_action_cooldown"></a> [scaling\_action\_cooldown](#input\_scaling\_action\_cooldown) | The amount of time to wait since the last scaling action before this action occurs for scale up | `string` | `"PT1M"` | no |
| <a name="input_scaling_action_instances_number"></a> [scaling\_action\_instances\_number](#input\_scaling\_action\_instances\_number) | The number of instances involved in the scaling action. Defaults to 1 | `string` | `"1"` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Name of sku | `string` | `"20_04-lts-gen2"` | no |
| <a name="input_sku_version"></a> [sku\_version](#input\_sku\_version) | Name of sku version | `string` | `"20.04.202209200"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the Virtual Machine | `string` | `"Standard_B2s"` | no |
| <a name="input_vmss_max_batch_instance_percent"></a> [vmss\_max\_batch\_instance\_percent](#input\_vmss\_max\_batch\_instance\_percent) | The maximum percent of total virtual machine instances that will be upgraded simultaneously by the rolling upgrade in one batch | `number` | `20` | no |
| <a name="input_vmss_max_unhealthy_instance_percent"></a> [vmss\_max\_unhealthy\_instance\_percent](#input\_vmss\_max\_unhealthy\_instance\_percent) | The maximum percentage of the total virtual machine instances in the scale set that can be simultaneously unhealthy, either as a result of being upgraded, or by being found in an unhealthy state by the virtual machine health checks before the rolling upgrade aborts | `number` | `20` | no |
| <a name="input_vmss_max_unhealthy_upgraded_instance_percent"></a> [vmss\_max\_unhealthy\_upgraded\_instance\_percent](#input\_vmss\_max\_unhealthy\_upgraded\_instance\_percent) | The maximum percentage of upgraded virtual machine instances that can be found to be in an unhealthy state | `number` | `20` | no |
| <a name="input_vmss_name"></a> [vmss\_name](#input\_vmss\_name) | Name of vmss | `string` | `"linux"` | no |
| <a name="input_vmss_pause_time_between_batches"></a> [vmss\_pause\_time\_between\_batches](#input\_vmss\_pause\_time\_between\_batches) | The wait time between completing the update for all virtual machines in one batch and starting the next batch. The time duration should be specified in ISO 8601 format. | `string` | `"PT0S"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linux_vmss_id"></a> [linux\_vmss\_id](#output\_linux\_vmss\_id) | Linux vmss id |
| <a name="output_linux_vmss_name"></a> [linux\_vmss\_name](#output\_linux\_vmss\_name) | Linux vmss name |
<!-- END_TF_DOCS -->