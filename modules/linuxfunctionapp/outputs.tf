output "service_plan_id" {
  description = "Id of service plan"
  value       = azurerm_service_plan.service_plan.id
}
output "storage_account_name" {
  description = "Name of storage accout"
  value       = azurerm_storage_account.storage_account.name
}
output "storage_account_access_key" {
  description = "Access key of storage account"
  value       = azurerm_storage_account.storage_account.primary_access_key
  sensitive   = true
}
output "linux_function_app_name" {
  description = "Name of linux function app"
  value       = azurerm_linux_function_app.linux_function_app.name
}
output "linux_function_app_id" {
  description = "Id of linux function app"
  value       = azurerm_linux_function_app.linux_function_app.id
}