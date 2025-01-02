variable "location" {
  description = "The location(region) where the resources will be created"
  type        = string
  default     = "southeastasia"
}
variable "resource_group" {
  description = "Default resource group name in which resources will be launch."
  type        = string
  default     = "sa1_test_eic_AbhinavJha"
}
variable "linux_function_app_network_region" {
  description = "Value for region"
  type        = string
  default     = "sa1"
}
variable "linux_function_app_object" {
  description = "Value of object type of the resource creating"
  type        = list(string)
  default     = ["salinux", "lsp", "lfa"]
}
variable "linux_function_app_service" {
  description = "Service name"
  type        = string
  default     = "ma"
}
variable "linux_function_app_function" {
  description = "Function of the resource"
  type        = string
  default     = "wb"
}
variable "linux_function_app_lifecycle" {
  description = "Lifecycle of resource according to environment"
  type        = string
  default     = "d"
}
variable "service_plan_name" {
  description = "Name of service plan"
  type        = list(string)
  default     = ["linux_service_plan01"]
}
variable "linux_function_app_account_tier" {
  default = "Standard"
}
variable "linux_function_app_account_replication_type" {
  default = "LRS"
}
variable "linux_function_app_os_type" {
  description = "Name of Operating system"
  type        = string
  default     = "Linux"
}
variable "linux_function_app_sku_name" {
  description = "Type of sku"
  type        = string
  default     = "Y1"
}
variable "linux_functionapp_name" {
  description = "Name of functionapp"
  type        = list(string)
  default     = ["linuxfunctionapp"]
}
variable "linux_functionapp_always_on" {
  description = "The URL of the API definition that describes this Windows Function App."
  type        = bool
  default     = false
}
variable "linux_functionapp_http2_enabled" {
  description = "Specifies if the HTTP2 protocol should be enabled."
  type        = bool
  default     = false
}
variable "linux_functionapp_load_balancing_mode" {
  description = "The Site load balancing mode."
  type        = string
  default     = "LeastRequests"
}
variable "linux_functionapp_managed_pipeline_mode" {
  description = "Managed pipeline mode."
  type        = string
  default     = "Integrated"
}
variable "linux_functionapp_minimum_tls_version" {
  description = "Configures the minimum version of TLS required for SSL requests."
  type        = string
  default     = "1.2"
}
variable "linux_functionapp_remote_debugging_enabled" {
  description = "Should Remote Debugging be enabled."
  type        = bool
  default     = true
}
variable "linux_functionapp_remote_debugging_version" {
  description = "The Remote Debugging Version."
  type        = string
  # default     = "VS2019"
  default     = "VS2022"
}
variable "linux_functionapp_ftps_state" {
  description = "State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled"
  type        = string
  default     = "Disabled"
}
variable "linux_functionapp_runtime_scale_monitoring_enabled" {
  description = "Should Scale Monitoring of the Functions Runtime be enabled?"
  type        = bool
  default     = false
}
variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
}
