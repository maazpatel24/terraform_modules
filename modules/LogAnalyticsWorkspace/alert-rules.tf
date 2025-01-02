locals {
  levels   = ["Verbose", "Informational", "Warning", "Error", "Critical"]
  statuses = ["Succeeded", "Failed"]
}

## Create policy assignment 
resource "azurerm_monitor_activity_log_alert" "policy-creation" {
  name                = "Create policy assignment"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [var.alert_scope_id]
  description         = "This alert monitors the creation of policy assignments in the specified resource group. It triggers when a 'write' operation is performed on Policy Assignments under the Microsoft.Authorization namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/PolicyAssignments/write"
    levels         = local.levels
    statuses       = local.statuses

  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Delete policy assignment
resource "azurerm_monitor_activity_log_alert" "policy-deletion" {
  name                = "Delete policy assignment"
  resource_group_name = var.resource_group_name
  scopes              = [var.alert_scope_id]
  location            = "global"
  description         = "This alert monitors the deletion of policy assignments in the specified resource group. It triggers when a 'delete' operation is performed on Policy Assignments under the Microsoft.Authorization namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/PolicyAssignments/delete"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Create or Update Network Security Group
resource "azurerm_monitor_activity_log_alert" "nsg-write" {
  name                = "Create or Update Network Security Group"
  resource_group_name = var.resource_group_name
  scopes              = [var.alert_scope_id]
  location            = "global"
  description         = "This alert monitors the creation or update of Network Security Groups (NSGs) within the specified resource group. It triggers when a 'write' operation is performed on Network Security Groups under the Microsoft.Network namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Delete Network Security Group
resource "azurerm_monitor_activity_log_alert" "nsg-deletion" {
  name                = "Delete Network Security Group"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [var.alert_scope_id]
  description         = "This alert monitors the deletion of Network Security Groups (NSGs) within the specified resource group. It triggers when a 'delete' operation is performed on Network Security Groups under the Microsoft.Network namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Create or Update Security Solution
resource "azurerm_monitor_activity_log_alert" "security-write" {
  name                = "Create or Update Security Solution"
  resource_group_name = var.resource_group_name
  scopes              = [var.alert_scope_id]
  location            = "global"
  description         = "This alert monitors the creation or update of security solutions within the specified resource group. It triggers when a 'write' operation is performed on security solutions under the Microsoft.OperationsManagement namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.OperationsManagement/solutions/write"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Delete Security Solution
resource "azurerm_monitor_activity_log_alert" "security-deletion" {
  name                = "Delete Security Solution"
  resource_group_name = var.resource_group_name
  scopes              = [var.alert_scope_id]
  location            = "global"
  description         = "This alert monitors the deletion of security solutions within the specified resource group. It triggers when a 'delete' operation is performed on security solutions under the Microsoft.OperationsManagement namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.OperationsManagement/solutions/delete"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Create or Update Public IP Address
resource "azurerm_monitor_activity_log_alert" "ip-write" {
  name                = "Create or Update Public IP Address"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [var.alert_scope_id]
  description         = "This alert monitors the creation or update of Public Ip Addresses within the specified resource group. It triggers when a 'write' operation is performed on Public Ip Addresses under the Microsoft.Network namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/publicIPAddresses/write"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}

## Delete Public IP Address
resource "azurerm_monitor_activity_log_alert" "ip-deletion" {
  name                = "Delete Public IP Address"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [var.alert_scope_id]
  description         = "This alert monitors the deletion of Public Ip Addresses within the specified resource group. It triggers when a 'delete' operation is performed on Public Ip Addresses under the Microsoft.Network namespace."
  tags                = var.tags
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/publicIPAddresses/delete"
    levels         = local.levels
    statuses       = local.statuses
  }
  action {
    action_group_id = azurerm_monitor_action_group.action-grp.id
  }
}