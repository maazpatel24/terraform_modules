output "storage_account_name" {
  description = "Storage Account Name"
  value       = azurerm_storage_account.storage_account.name
}
output "container_name" {
  description = "Container name"
  value       = azurerm_storage_container.container[*].name
}
output "container_id" {
  description = "Id of the container"
  value       = azurerm_storage_container.container[*].id
}
output "file_share_id" {
  description = "Id of file share"
  value       = azurerm_storage_share.file_share[*].id
}
output "file_share_name" {
  description = "Name of file share"
  value       = azurerm_storage_share.file_share[*].name
}
output "queue_id" {
  description = "Queue id"
  value       = azurerm_storage_queue.queue[*].id
}
output "queue_name" {
  description = "Queue name"
  value       = azurerm_storage_queue.queue[*].name
}
output "table_id" {
  description = "Storage table id"
  value       = azurerm_storage_table.table[*].id
}
output "table_name" {
  description = "Storage table name"
  value       = azurerm_storage_table.table[*].name
}