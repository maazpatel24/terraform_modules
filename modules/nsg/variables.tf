variable "location" {}
variable "resource_group" {}
variable "prefix" {}
variable "env" {}
variable "network_security_group_name" {}
variable "tags" {}

variable "custom_rules" {
  description = "Custom rules defined by user"
  type = list(object({
    access                     = string
    direction                  = string
    name                       = string
    priority                   = number
    protocol                   = string
    description                = string
    destination_address_prefix  = string
    destination_address_prefixes = optional(list(string))
    destination_port_range      = string
    source_address_prefix      = string
    source_address_prefixes    = optional(list(string))
    source_port_range          = string
  }))
  default = [
    {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "Allow_HTTP"
      priority                   = 100
      protocol                   = "Tcp"
      description                = "Allow HTTP traffic"
      destination_address_prefix  = "*"
      destination_port_range      = "80"
      source_address_prefix      = "*"
      source_port_range          = "*"
    },
    {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "Allow_HTTPS"
      priority                   = 110
      protocol                   = "Tcp"
      description                = "Allow HTTPS traffic"
      destination_address_prefix  = "*"
      destination_port_range      = "443"
      source_address_prefix      = "*"
      source_port_range          = "*"
    },
    {
      access                     = "Deny"
      direction                  = "Inbound"
      name                       = "Deny_All_Other"
      priority                   = 200
      protocol                   = "*"
      description                = "Deny all other inbound traffic"
      destination_address_prefix  = "*"
      destination_port_range      = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  ]
}
