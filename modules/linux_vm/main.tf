#------------------------------
#  Linux vm Public Ip
#------------------------------
resource "azurerm_public_ip" "linuxvmpublicip" {
  count               = length(var.public_ip_name)
  name                = var.public_ip_name[count.index]
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = var.allocation_method
  tags                = var.tags
}

#------------------------------
#  Linux vm network interface
#------------------------------
resource "azurerm_network_interface" "linuxvmnic" {
  count               = length(var.nic_name)
  name                = var.nic_name[count.index]
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = azurerm_public_ip.linuxvmpublicip[count.index].name
    subnet_id                     = var.pub_subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation_method
    public_ip_address_id          = azurerm_public_ip.linuxvmpublicip[count.index].id
  }

  tags = var.tags
}

#------------------------------
#  Linux vm NSG Association
#------------------------------
resource "azurerm_network_interface_security_group_association" "linuxvmnsga" {
  count                     = length(var.nic_name)
  network_interface_id      = azurerm_network_interface.linuxvmnic[count.index].id
  network_security_group_id = var.nsg_id
}

#------------------------------
#  Linux Virtual Machine
#------------------------------
resource "azurerm_virtual_machine" "linuxvm" {
  count                 = length(var.vm_name)
  name                  = var.vm_name[count.index]
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.linuxvmnic[count.index].id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.linux_publisher
    offer     = var.linux_offer
    sku       = var.linux_sku
    version   = var.linux_sku_version
  }
  storage_os_disk {
    name              = var.vm_name[count.index]
    caching           = var.caching
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
  }
  os_profile {
    computer_name  = var.vm_name[count.index]
    admin_username = var.admin_username
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.key_data
    }
  }

  tags = var.tags
}






