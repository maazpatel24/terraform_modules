variable "location" {
  description = "The location(region) where the resources will be created."
  type        = string
}
variable "resource_group" {
  description = "Default resource group name in which resources will be launch."
  type        = string
}
variable "prefix" {
  description = "Prefix to be added with all resources."
  type        = string
}
variable "env" {
  description = "The name of the current environment."
  type        = string
}
variable "keyvault_name" {
  description = "The name of the Key Vault."
  type        = string
}
variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault."
  type        = string
}
variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted."
  type        = number
}
variable "key_name" {
  description = "The name of the keyvault key."
  type        = list(string)
}
variable "key_type" {
  description = "Specifies the Key Type to use for this Key Vault Key."
  type        = string
}
variable "key_size" {
  description = "Specifies the Size of the RSA key to create in bytes."
  type        = number
}
variable "time_before_expiry" {
  description = "Rotate automatically at a duration before expiry as an ISO 8601 duration."
  type        = string
}
variable "expire_after" {
  description = "Expire a Key Vault Key after given duration as an ISO 8601 duration."
  type        = string
}
variable "notify_before_expiry" {
  description = "Notify at a given duration before expiry as an ISO 8601 duration."
  type        = string
}
variable "secret_permissions" {
  description = "List of secret permissions."
  type        = list(string)
}
variable "key_opts" {
  description = "A list of JSON web key operations."
  type        = list(string)
}
variable "key_permissions" {
  description = "List of key permissions."
  type        = list(string)
}
variable "storage_permissions" {
  description = "List of storage permissions."
  type        = list(string)
}
variable "tags" {
  description = "A map of the tags to use for the resources that are deployed."
  type        = map(string)
}