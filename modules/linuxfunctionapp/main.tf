
#---------------------------------------------------
#Locals for creating string
#---------------------------------------------------
locals {
  network_region = var.linux_function_app_network_region
  object         = var.linux_function_app_object
  service        = var.linux_function_app_service
  function       = var.linux_function_app_function
  lifecycle      = var.linux_function_app_lifecycle

  storage_account_name    = "${local.network_region}${local.object[0]}${local.service}${local.function}${local.lifecycle}"
  service_plan_name       = "${local.network_region}${local.object[1]}${local.service}${local.function}${local.lifecycle}"
  linux_function_app_name = "${local.network_region}${local.object[2]}${local.service}${local.function}${local.lifecycle}"
}

#---------------------------------------------------
#Creating storage account
#---------------------------------------------------
resource "azurerm_storage_account" "storage_account" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = var.linux_function_app_account_tier
  account_replication_type = var.linux_function_app_account_replication_type
}

#---------------------------------------------------
#Creating Service plan
#---------------------------------------------------
resource "azurerm_service_plan" "service_plan" {
  name                = local.service_plan_name
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = var.linux_function_app_os_type
  sku_name            = var.linux_function_app_sku_name
}

#---------------------------------------------------
#Creating linux function app
#---------------------------------------------------
resource "azurerm_linux_function_app" "linux_function_app" {
  name                = local.linux_function_app_name
  resource_group_name = var.resource_group
  location            = var.location

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  site_config {
    always_on                        = var.linux_functionapp_always_on
    http2_enabled                    = var.linux_functionapp_http2_enabled
    load_balancing_mode              = var.linux_functionapp_load_balancing_mode
    managed_pipeline_mode            = var.linux_functionapp_managed_pipeline_mode
    minimum_tls_version              = var.linux_functionapp_minimum_tls_version
    remote_debugging_enabled         = var.linux_functionapp_remote_debugging_enabled
    remote_debugging_version         = var.linux_functionapp_remote_debugging_version
    ftps_state                       = var.linux_functionapp_ftps_state
    runtime_scale_monitoring_enabled = var.linux_functionapp_runtime_scale_monitoring_enabled
  }
}