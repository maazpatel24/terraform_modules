resource "azurerm_postgresql_flexible_server_configuration" "server_parameter" {
  for_each = var.server_parameter_list
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.psql-server.id
  value     = each.value
}


## Diagnostic Settings for AppManagement API
resource "azurerm_monitor_diagnostic_setting" "diag_settings_postgres" {
  name                       = "${azurerm_postgresql_flexible_server.psql-server.name}-diag-settings"
  target_resource_id         = azurerm_postgresql_flexible_server.psql-server.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
  category_group = "audit"
  }
  enabled_log {
    category_group = "AllLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}