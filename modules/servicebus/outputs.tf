output "servicebus_namespace_name" {
  description = "Namespace name of Service Bus"
  value       = azurerm_servicebus_namespace.servicebus.name
}
output "servicebus_namespace_id" {
  description = "Namespace ID of Service Bus"
  value       = azurerm_servicebus_namespace.servicebus.id
}
output "servicebus_queue_id" {
  description = "ID of Service Bus Queue"
  value       = azurerm_servicebus_queue.servicebusqueue[*].id
}
output "servicebus_queue_name" {
  description = "Name of the Service Bus Queue"
  value       = azurerm_servicebus_queue.servicebusqueue[*].name
}
output "servicebus_authorization_rule_id" {
  description = "ID of the Authorization rule"
  value       = azurerm_servicebus_namespace_authorization_rule.policy[*].id
}