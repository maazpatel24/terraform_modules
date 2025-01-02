## Data Lake Gen2 Storage account
resource "azurerm_storage_account" "datalake-storage-account" {
  name                              = "${var.env}${var.prefix}dlkgenteryrt018"
  tags                              = var.tags
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.cool_account_tier
  account_replication_type          = var.cool_replication_type
  access_tier                       = "Hot"
  account_kind                      = "StorageV2"
  is_hns_enabled                    = "true"
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  blob_properties {
    last_access_time_enabled = true
  }
  #  network_rules {
  #    default_action = "Deny"
  #    bypass = ["AzureServices"]
  #    private_link_access {
  #      endpoint_resource_id = var.stream_analytics_id
  #    }
  #  }
  identity {
    type = "SystemAssigned"
  }
}

##Assign access to stream analytics user managed identity
#resource "azurerm_role_assignment" "streamjob-access" {
#  principal_id         = var.streamjob_principal_id
#  role_definition_name = "Storage Blob Data Contributor"
#  scope                = azurerm_storage_account.datalake-storage-account.id
#}


## Data Lake Storage: DeviceData Container
resource "azurerm_storage_container" "deivcedata-container" {
  name                  = "devicedata-hotstorage"
  storage_account_name  = azurerm_storage_account.datalake-storage-account.name
  container_access_type = var.container_access_type
}

## Data Lake Storage: Blob Secret
# resource "azurerm_key_vault_secret" "datalake-blob-secret" {
#   name            = "${azurerm_storage_account.datalake-storage-account.name}-secret"
#   value           = azurerm_storage_account.datalake-storage-account.primary_connection_string
#   key_vault_id    = var.keyvault_id
#   expiration_date = timeadd(timestamp(), "${var.secret_expire_duration}h")
#   lifecycle {
#     ignore_changes = [expiration_date]
#   }
# }

# ## Data Lake Storage: Lifecycle policy
# resource "azurerm_storage_management_policy" "datalake-lifecycle-policy" {
#   storage_account_id = azurerm_storage_account.datalake-storage-account.id
#   rule {
#     name    = "Blob-deletion-rule"
#     enabled = true
#     filters {
#       blob_types = ["blockBlob"]
#     }
#     actions {
#       base_blob {
#         delete_after_days_since_creation_greater_than = 90
#       }
#     }
#   }
# }
 