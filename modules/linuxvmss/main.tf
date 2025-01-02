
#--------------------------------------------
# Linux Virtual machine scale set 
#--------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "linuxvmss" {
  name                = "${var.env}${var.prefix}${var.vmss_name}"
  location            = var.location
  resource_group_name = var.resource_group
  upgrade_mode        = var.os_upgrade_mode
  sku                 = var.vm_size
  instances           = var.instances_count
  admin_username      = var.admin_username
  provision_vm_agent  = true

  source_image_reference {
    publisher = var.publisher
    offer     = "0001-com-ubuntu-server-focal"
    sku       = var.sku
    version   = var.sku_version
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  os_disk {
    storage_account_type = var.os_disk_type
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.env}${var.prefix}-linuxnic"
    primary = true

    ip_configuration {
      name      = "IPConfiguration"
       subnet_id = var.linux_subnet_id
      primary   = true
      #application_gateway_backend_address_pool_ids = var.appgateway_backend_address_pool_id
    }
  }

  tags = var.tags
}
