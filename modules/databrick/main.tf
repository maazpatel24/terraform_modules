
#---------------------------------------------
#Creating Databrick
#---------------------------------------------
resource "azurerm_databricks_workspace" "databrick_workspace" {
  count               = length(var.workspace_name)
  name                = var.workspace_name[count.index]
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.workspace_sku
  managed_resource_group_name = var.managed_resource_group_name[count.index]
  tags = var.tags
}
