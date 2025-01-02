#-----------------------------------------------------
#Creating Auto scaling setting
#-----------------------------------------------------
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.env}${var.prefix}-linux-autoscale"
  resource_group_name = var.resource_group
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.linuxvmss.id

  profile {
    name = "default"
    capacity {
      default = var.instances_count
      minimum = var.minimum_instances_count
      maximum = var.maximum_instances_count
    }

    rule {
      metric_trigger {
        metric_name        = var.increase_metric_name
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linuxvmss.id
        operator           = var.increase_operator
        statistic          = var.increase_statistic
        threshold          = var.increase_threshold
        time_aggregation   = var.increase_time_aggregation
        time_grain         = var.increase_time_grain
        time_window        = var.increase_time_window
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = var.scaling_action_cooldown
      }
    }

    rule {
      metric_trigger {
        metric_name        = var.decrease_metric_name
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linuxvmss.id
        operator           = var.decrease_operator
        statistic          = var.decrease_statistic
        threshold          = var.decrease_threshold
        time_aggregation   = var.decrease_time_aggregation
        time_grain         = var.decrease_time_grain
        time_window        = var.decrease_time_window
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.scaling_action_instances_number
        cooldown  = var.scaling_action_cooldown
      }
    }
  }
  tags = var.tags
}