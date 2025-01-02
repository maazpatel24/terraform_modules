
#-------------------------------
# Creating Storage Account
#-------------------------------
resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.env}${var.prefix}${var.storage_account_name}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = var.tier
  account_replication_type = var.replication_type

   tags = var.tags
}

#-------------------------------
# Creating Container
#-------------------------------
resource "azurerm_storage_container" "container" {
  count                 = var.container_name != "" ? length(var.container_name) : 0
  name                  = var.container_name[count.index]
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
}

#-------------------------------
# Creating Fileshare
#-------------------------------
resource "azurerm_storage_share" "file_share" {
  count                = var.file_share_name != "" ? length(var.file_share_name) : 0
  name                 = var.file_share_name[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = var.quota
}

#-------------------------------
# Creating Queue
#-------------------------------
resource "azurerm_storage_queue" "queue" {
  count                = var.queue_name != "" ? length(var.queue_name) : 0
  name                 = var.queue_name[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
}

#-------------------------------
# Creating Table
#-------------------------------
resource "azurerm_storage_table" "table" {
  count                = var.table_name != "" ? length(var.table_name) : 0
  name                 = var.table_name[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
}