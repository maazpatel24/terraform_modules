variable "env" {
  description = "The environment for the deployment (e.g., dev, qa, prod)."
  type        = string
}
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
}
variable "prefix" {
  description = "A prefix to use for naming resources."
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}
variable "cool_replication_type" {
  description = "Defines the type of replication to use for Cool storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
}
variable "cool_account_tier" {
  description = "Defines the Tier to use for Cool storage account. Valid options are Standard and Premium."
  type        = string
}
# variable "vnet_name" {}
# variable "vnet_range" {}
# variable "hot_replication_type" {
#   description = "Defines the type of replication to use for Hot storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
#   type        = string
# }
# variable "hot_account_tier" {
#   description = "Defines the Tier to use for Hot storage account. Valid options are Standard and Premium."
#   type        = string
# }
# variable "cool_container_name" {
#   description = "The name of the Container which should be created within the Cool Storage Account."
#   type        = string
# }
variable "container_access_type" {
  description = "The Access Level configured for this Container. Possible values are blob, container or private. Defaults to private."
  type        = string
}
# # variable "hot_container_name" {}
# variable "private_dnszone_id" {
#   description = "Specifies the list of Private DNS Zones to include within the private_dns_zone_group."
#   type        = string
# }
# variable "private_dnszone_name" {
#   description = "Specifies the Private DNS Zone where the resource exists."
#   type        = string
# }
# variable "hot-sa-subnet" {
#   description = "The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint."
#   type        = string
# }
# variable "keyvault_id" {
#   description = "The ID of the Key Vault."
#   type        = string
# }
# variable "vnet-id" {}
# variable "appservice_subnet" {}
# variable "function_subnet" {}
# variable "stream_analytics_subnet" {}
# variable "stream_analytics_id" {}
# variable "eic_network_ips" {}
# //variable "streamjob_principal_id" {}
# variable "secret_expire_duration" {}