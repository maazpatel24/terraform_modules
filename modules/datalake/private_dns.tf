# ########Creating private dns zone for Environmet.

# resource "azurerm_private_dns_zone" "privatedns" {
#   name                = "${var.env}${var.prefix}datalake.com"
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# ########Linking private dns zones with the vnet
# resource "azurerm_private_dns_zone_virtual_network_link" "vnet-link" {
#   name                  = "vnetconnection"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.privatedns.name
#   virtual_network_id    = data.azurerm_virtual_network.vnet-01
#   registration_enabled  = true
# }