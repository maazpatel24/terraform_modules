output "linuxvm_name" {
  description = "Name of linux virtual machine"
  value       = azurerm_virtual_machine.linuxvm[*].name
}
output "linux_vm_public_ip" {
  description = "Public ip address of linux virtual machine"
  value       = azurerm_public_ip.linuxvmpublicip[*].ip_address
}