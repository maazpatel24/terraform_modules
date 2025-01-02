resource "azurerm_log_analytics_workspace" "log-workspace" {
  name                = "${var.env}-${var.prefix}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

## Action Group for Alert Rules
resource "azurerm_monitor_action_group" "action-grp" {
  name                = "${var.env}-${var.prefix}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "${var.prefix}alertgrp"
  dynamic "email_receiver" {
    for_each = var.action_grp_member
    content {
      name          = "${element(split("@", email_receiver.value), 0)}-email"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}
#### for QA and Staging use below data block to access log analytics workspace
#data "azurerm_log_analytics_workspace" "log-workspace" {
#  count = var.env == "qa" ? 1 : 0
#  name                = "${var.prefix}-log_analytics_workspace"
#  resource_group_name = var.workspace_rg_name
#}