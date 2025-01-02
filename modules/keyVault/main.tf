
#-------------------------------------------------
# Access the configuration of the AzureRM provider
#-------------------------------------------------
data "azurerm_client_config" "current" {}


#----------------------------------
# Create Key Vault to store Secrets
#----------------------------------
resource "azurerm_key_vault" "keyvault" {
  location                   = var.location
  name                       = "${var.env}-${var.prefix}-${var.keyvault_name}"
  resource_group_name        = var.resource_group
  sku_name                   = var.sku_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    key_permissions     = var.key_permissions != [] ? var.key_permissions : []
    secret_permissions  = var.secret_permissions != [] ? var.secret_permissions : []
    storage_permissions = var.storage_permissions != [] ? var.storage_permissions : []
  }

  # tags = var.tags
}


#----------------------------------
# Create Key for Key-Vault
#----------------------------------
resource "azurerm_key_vault_key" "keyvault_key" {
  count        = length(var.key_name)
  name         = "${var.env}-${var.prefix}-${var.key_name[count.index]}"
  key_vault_id = azurerm_key_vault.keyvault.id
  key_type     = var.key_type
  key_size     = var.key_size

  // depends_on = [
  //   azurerm_key_vault_access_policy.kvkuser
  // ]

  key_opts = var.key_opts

  rotation_policy {
    automatic {
      time_before_expiry = var.time_before_expiry
    }
    expire_after         = var.expire_after
    notify_before_expiry = var.notify_before_expiry
  }

  # tags = var.tags
}


#----------------------------------
# Create key vault access policy
#----------------------------------
// resource "azurerm_key_vault_access_policy" "kvkuser" {
//   key_vault_id = azurerm_key_vault.keyvault.id

//   tenant_id = data.azurerm_client_config.current.tenant_id
//   object_id = data.azurerm_client_config.current.object_id

//   key_permissions = var.key_permissions

// }