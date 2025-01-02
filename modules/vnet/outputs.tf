output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.vnet.name
}
output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.vnet.id
}
output "subnet_name" {
  description = "Subnet name"
  value       = azurerm_subnet.publicsubnet[*].name
}
output "subnet_id" {
  description = "Subnet id"
  value       = azurerm_subnet.publicsubnet[*].id
}

output "subnet_id1" {
  description = "Subnet id"
  value       = azurerm_subnet.publicsubnet[0].id
}

output "subnet_id2" {
  description = "Subnet id"
  value       = azurerm_subnet.publicsubnet[1].id
}