variable "location" {
  description = "The location(region) where the resources will be created"
  type        = string
}
variable "resource_group" {
  description = "Default resource group name in which resources will be launch."
  type        = string
}
variable "workspace_name" {
  type        = list(string)
  description = "The name of the Azure Databricks workspace."
}
variable "workspace_sku" {
  type        = string
  description = "The SKU name for the Databricks workspace."
}
variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
}
variable "managed_resource_group_name" {
   type    = list(string)
}
