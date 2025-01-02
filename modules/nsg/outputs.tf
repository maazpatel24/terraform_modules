output "nsg_id" {
  description = "Id of network security group"
  value = azurerm_network_security_group.nsg.id
}
output "nsg_name" {
  description = "Name of network security group"
  value = azurerm_network_security_group.nsg.name
}