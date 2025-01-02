output "event_hub_namespace_id" {
  description = "Eventhub namespace id"
  value       = azurerm_eventhub_namespace.eventhub_namespace.id
}
output "event_hub_namespace_name" {
  description = "Eventhub namespace id"
  value       = azurerm_eventhub_namespace.eventhub_namespace.name
}
output "eventhub_id" {
  description = "Eventhub id"
  value       = azurerm_eventhub.eventhub[*].id
}
output "eventhub_name" {
  description = "Eventhub name"
  value       = azurerm_eventhub.eventhub[*].name
}