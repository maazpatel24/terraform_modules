#output "primary_blob_connection_string" {
#  value = azurerm_storage_account.cool-storage.primary_blob_connection_string
#}
# output "cool_container" {
#   value = azurerm_storage_container.cool_container.name
# }
# output "hot_storage" {
#   value = azurerm_storage_account.hot-storage.id
# }
# output "hot_storage_name" {
#   value = azurerm_storage_account.hot-storage.name
# }
# output "hot_storage_access_key" {
#   value = azurerm_storage_account.hot-storage.primary_access_key
# }
# output "hotstorage_connection_secret_name" {
#   value = azurerm_key_vault_secret.hotstorage-blob-secret.name
# }
# output "hot_storage_connection_string" {
#   value = azurerm_key_vault_secret.hotstorage-conectionstring-secret.value
# }
output "datalake_storage_name" {
  value = azurerm_storage_account.datalake-storage-account.name
}
output "datalake_storage_connection_key" {
  value = azurerm_storage_account.datalake-storage-account.primary_access_key
}
output "datalek_container_name" {
  value = azurerm_storage_container.deivcedata-container.name
}
# output "cool_storage_account" {
#   value = azurerm_storage_account.cool-storage.name
# }
# output "cool_storage_connection_key" {
#   value = azurerm_storage_account.cool-storage.primary_access_key
# }
# output "datalake_blob_connection_secret_name" {
#   value = azurerm_key_vault_secret.datalake-blob-secret.name
# }
# output "webpublic_container_name" {
#   value = azurerm_storage_container.webpublic-container.name
# }
# output "cool_account_id" {
#   value = azurerm_storage_account.cool-storage.id
# }
# output "cool_account_endpoint" {
#   value = azurerm_storage_account.cool-storage.primary_blob_endpoint
# }
# output "hot_container_names" {
#   value = [azurerm_storage_container.webprivate-container.name, azurerm_storage_container.webpublic-container.name]
# }