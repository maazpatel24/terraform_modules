#------------------------------------------------
#Creating Network security group
#------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.env}${var.prefix}_${var.network_security_group_name}"
  resource_group_name = var.resource_group
  location            = var.location
  
  tags                = var.tags
}

#-------------------------------------------------------
#Creating Network security group custom rules
#-------------------------------------------------------
resource "azurerm_network_security_rule" "custom_rules" {
  count                        = length(var.custom_rules)
  access                       = lookup(var.custom_rules[count.index], "access", "Allow")
  direction                    = lookup(var.custom_rules[count.index], "direction", "Inbound")
  name                         = lookup(var.custom_rules[count.index], "name", "rule01")
  network_security_group_name  = azurerm_network_security_group.nsg.name
  priority                     = lookup(var.custom_rules[count.index], "priority")
  protocol                     = lookup(var.custom_rules[count.index], "protocol", "*")
  resource_group_name          = var.resource_group
  description                  = lookup(var.custom_rules[count.index], "description", "Security rule for ${lookup(var.custom_rules[count.index], "name", "rule01")}")
  destination_address_prefix   = lookup(var.custom_rules[count.index], "destination_address_prefix", "*")
  destination_address_prefixes = lookup(var.custom_rules[count.index], "destination_address_prefixes", null)
  destination_port_ranges      = split(",", replace(lookup(var.custom_rules[count.index], "destination_port_range", "*"), "*", "0-65535"))
  source_address_prefix        = lookup(var.custom_rules[count.index], "source_address_prefix", "*")
  source_address_prefixes      = lookup(var.custom_rules[count.index], "source_address_prefixes", null)
  source_port_range            = lookup(var.custom_rules[count.index], "source_port_range", "*") == "*" ? "*" : null
  source_port_ranges           = lookup(var.custom_rules[count.index], "source_port_range", "*") == "*" ? null : [for r in split(",", var.custom_rules[count.index].source_port_range) : trimspace(r)]
}