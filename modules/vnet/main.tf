
#-------------------------------
# Creatong Virtual Network
#-------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}${var.prefix}-${var.vnet_name}"
  address_space       = var.net_range
  location            = var.location
  resource_group_name = var.resource_group

  tags = var.tags
}

#-------------------------------
# Creating Subnet
#-------------------------------
resource "azurerm_subnet" "publicsubnet" {
  count                = length(var.subnet_name)
  name                 = "${var.env}${var.prefix}_${var.subnet_name[count.index]}"
  address_prefixes     = [var.subnet_range[count.index]]
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
}