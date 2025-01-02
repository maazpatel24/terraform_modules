
#---------------------------------------------
# Creating namespace for eventhub
#---------------------------------------------
resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  name                = var.eventhub_namespace_name
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.eventhub_sku
  capacity            = var.capacity

  tags = var.tags
}

#---------------------------------------------
# Creating eventhub
#---------------------------------------------
resource "azurerm_eventhub" "eventhub" {
  count               = length(var.eventhub_name)
  name                = var.eventhub_name[count.index]
  namespace_name      = azurerm_eventhub_namespace.eventhub_namespace.name
  resource_group_name = var.resource_group
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}