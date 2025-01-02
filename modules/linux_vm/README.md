<!-- BEGIN_TF_DOCS -->
## Introduction
This module creates Linux virtual machine.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.linuxvmnic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.linuxvmnsga](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.linuxvmpublicip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.linuxvm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | adminusername for virtual machine | `string` | `"azureadmin"` | no |
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | Allocation method for IP address | `string` | `"Static"` | no |
| <a name="input_caching"></a> [caching](#input\_caching) | Type of Caching which should be used for the Internal OS Disk | `string` | `"ReadWrite"` | no |
| <a name="input_env"></a> [env](#input\_env) | provide current environment name | `string` | `"dev"` | no |
| <a name="input_key_data"></a> [key\_data](#input\_key\_data) | ssh public key information user can create their own ssh\_key or use existing ssh\_key | `string` | n/a | yes |
| <a name="input_linux_offer"></a> [linux\_offer](#input\_linux\_offer) | Specifies the offer of the image used to create the virtual machines | `string` | `"0001-com-ubuntu-server-focal"` | no |
| <a name="input_linux_publisher"></a> [linux\_publisher](#input\_linux\_publisher) | Name of the publisher | `string` | `"Canonical"` | no |
| <a name="input_linux_sku"></a> [linux\_sku](#input\_linux\_sku) | Name of sku | `string` | `"20_04-lts-gen2"` | no |
| <a name="input_linux_sku_version"></a> [linux\_sku\_version](#input\_linux\_sku\_version) | Name of sku version | `string` | `"20.04.202209200"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location(region) where the resources will be created | `string` | `"eastus"` | no |
| <a name="input_managed_disk_type"></a> [managed\_disk\_type](#input\_managed\_disk\_type) | Type of managed disk | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_nic_name"></a> [nic\_name](#input\_nic\_name) | Name of network interface | `list(string)` | <pre>[<br>  "linuxnic01"<br>]</pre> | no |
| <a name="input_nsg_id"></a> [nsg\_id](#input\_nsg\_id) | Network security group id | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"eic"` | no |
| <a name="input_private_ip_address_allocation_method"></a> [private\_ip\_address\_allocation\_method](#input\_private\_ip\_address\_allocation\_method) | Allocation method for private IP address | `string` | `"Dynamic"` | no |
| <a name="input_pub_subnet_id"></a> [pub\_subnet\_id](#input\_pub\_subnet\_id) | Subnet id | `string` | n/a | yes |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Name of public ip addresses | `list(string)` | <pre>[<br>  "public_ip01"<br>]</pre> | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Default resource group name in which resources will be launch. | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use for the resources that are deployed | `map(string)` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the virtual machines | `list(string)` | <pre>[<br>  "linuxvm01"<br>]</pre> | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of virtual machine | `string` | `"Standard_B2ms"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linux_vm_public_ip"></a> [linux\_vm\_public\_ip](#output\_linux\_vm\_public\_ip) | Public ip address of linux virtual machine |
| <a name="output_linuxvm_name"></a> [linuxvm\_name](#output\_linuxvm\_name) | Name of linux virtual machine |
<!-- END_TF_DOCS -->