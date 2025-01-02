output "iothub_name" {
  description = "IOT hub name"
  value       = azurerm_iothub.iothub.*.name
}
output "iothub_id" {
  description = "IOT hub id"
  value       = azurerm_iothub.iothub.*.id
}