output "linux_vmss_name" {
  description = "Linux vmss name"
  value       = azurerm_linux_virtual_machine_scale_set.linuxvmss.name
}
output "linux_vmss_id" {
  description = "Linux vmss id"
  value       = azurerm_linux_virtual_machine_scale_set.linuxvmss.id
}
