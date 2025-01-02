
#---------------------------------------------
# Creating iothub
#---------------------------------------------
resource "azurerm_iothub" "iothub" {
  count               = length(var.iothub_name)
  name                = var.iothub_name[count.index]
  resource_group_name = var.resource_group
  location            = var.location
  sku {
    name     = var.iothub_sku
    capacity = var.capacity
  }

   tags = var.tags
}