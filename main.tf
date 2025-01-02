
module "ssh_key" {
  source         = "./modules/sshkey"
  file_name      = var.file_name
  resource_group = var.resource_group
  location       = var.location
  algorithm      = var.algorithm
  tags           = var.tags
}

module "vnet" {
  source         = "./modules/vnet"
  resource_group = var.resource_group
  env            = var.env
  prefix         = var.prefix
  location       = var.location
  vnet_name      = var.vnet_name
  subnet_name    = var.subnet_name
  net_range      = var.net_range
  subnet_range   = var.subnet_range
  tags           = var.tags
}

module "nsg" {
  source                      = "./modules/nsg"
  env                         = var.env
  prefix                      = var.prefix
  resource_group              = var.resource_group
  location                    = var.location
  network_security_group_name = var.network_security_group_name
  tags                        = var.tags
}

module "linuxvm" {
  source            = "./modules/linux_vm"
  location          = var.location
  env               = var.env
  prefix            = var.prefix
  resource_group    = var.resource_group
  vm_name           = var.vm_name
  vm_size           = var.vm_size
  allocation_method = var.allocation_method
  private_ip_address_allocation_method = var.private_ip_address_allocation_method
  nic_name          = var.nic_name
  linux_publisher   = var.linux_publisher
  linux_offer       = var.linux_offer
  linux_sku         = var.linux_sku
  linux_sku_version = var.linux_sku_version
  managed_disk_type = var.managed_disk_type
  public_ip_name    = var.public_ip_name
  admin_username    = var.admin_username
  key_data          = var.key_data
  caching           = var.caching
  nsg_id            = module.nsg.nsg_id
  pub_subnet_id     = module.vnet.subnet_id1
  tags              = var.tags
}

module "linuxvmss" {
  source                  = "./modules/linuxvmss"
  resource_group          = var.resource_group
  location                = var.location
  env = var.env
  prefix = var.prefix
  vmss_name               = var.vmss_name
  vm_size                 = var.vm_size
  public_key              = var.key_data
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  os_disk_type            = var.os_disk_type
  os_upgrade_mode         = var.os_upgrade_mode
  vmss_max_batch_instance_percent = var.vmss_max_batch_instance_percent
  vmss_max_unhealthy_upgraded_instance_percent = var.vmss_max_unhealthy_upgraded_instance_percent
  vmss_max_unhealthy_instance_percent = var.vmss_max_unhealthy_instance_percent
  vmss_pause_time_between_batches = var.vmss_pause_time_between_batches
  instances_count         = var.instances_count
  minimum_instances_count = var.minimum_instances_count
  maximum_instances_count = var.maximum_instances_count
  scaling_action_instances_number = var.scaling_action_instances_number
  increase_operator = var.increase_operator
  increase_time_grain = var.increase_time_grain
  increase_time_window = var.increase_time_window
  increase_metric_name = var.increase_metric_name
  increase_time_aggregation = var.increase_time_aggregation
  increase_statistic = var.increase_statistic
  decrease_statistic = var.decrease_statistic
  decrease_time_aggregation = var.decrease_time_aggregation
  decrease_time_grain = var.decrease_time_grain
  decrease_time_window = var.decrease_time_window
  decrease_metric_name = var.decrease_metric_name
  decrease_operator = var.decrease_operator
  increase_threshold      = var.increase_threshold
  decrease_threshold      = var.decrease_threshold
  scaling_action_cooldown = var.scaling_action_cooldown
  publicip = var.publicip
  publisher = var.publisher
  sku                     = var.sku
  sku_version             = var.sku_version
  admin_username          = var.admin_username
  linux_subnet_id         = module.vnet.subnet_id1
  tags                    = var.tags

}

module "acr" {
  source         = "./modules/acr"
  resource_group = var.resource_group
  env = var.env
  prefix = var.prefix
  location       = var.location
  acr_sku        = var.acr_sku

}

module "aksCluster" {
  source                              = "./modules/aksCluster"
  resource_group                      = var.resource_group
  location                            = var.location
  aks_version                         = var.aks_version
  node_labels                         = var.node_labels
  tags                                = var.tags
  cluster_name                        = var.cluster_name
  identity_type                       = var.identity_type
  user_assigned_identity              = var.user_assigned_identity
  sku_tier                            = var.sku_tier
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  run_command_enabled                 = var.run_command_enabled
  public_network_access_enabled       = var.public_network_access_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  image_cleaner_enabled               = var.image_cleaner_enabled
  image_cleaner_interval_hours        = var.image_cleaner_interval_hours
  workload_identity_enabled           = var.workload_identity_enabled
  enable_auto_scaling                 = var.enable_auto_scaling
  prefix = var.prefix
  env = var.env
}

module "eventhub" {
  source                  = "./modules/eventhub"
  resource_group          = var.resource_group
  location                = var.location
  env = var.env
  prefix = var.prefix
  eventhub_namespace_name = var.eventhub_namespace_name
  eventhub_name           = var.eventhub_name
  eventhub_sku            = var.eventhub_sku
  capacity                = var.capacity
  partition_count         = var.partition_count
  message_retention       = var.message_retention
  tags                    = var.tags
}

module "iothub" {
  source         = "./modules/iothub"
  resource_group = var.resource_group
  location       = var.location
  env = var.env
  prefix = var.prefix
  iothub_name    = var.iothub_name
  iothub_sku     = var.iothub_sku
  capacity       = var.capacity
  tags           = var.tags
}

module "storage_account" {
  source               = "./modules/storageContainer"
  resource_group       = var.resource_group
  location             = var.location
  env = var.env
  prefix = var.prefix
  storage_account_name = var.storage_account_name
  tier = var.tier
  tags                 = var.tags
  container_name       = var.container_name
  table_name           = var.table_name
  queue_name           = var.queue_name
  file_share_name      = var.file_share_name
  replication_type     = var.replication_type
  container_access_type = var.container_access_type
  quota                 = var.quota
}


module "rediscache" {
  source                         = "./modules/rediscache"
  prefix = var.prefix
  env = var.env
  resource_group                 = var.resource_group
  location                       = var.location
  redis_cache_name               = var.redis_cache_name
  rediscache_capacity            = var.rediscache_capacity
  rediscache_family              = var.rediscache_family
  rediscache_enable_non_ssl_port = var.rediscache_enable_non_ssl_port
  rediscache_sku_name            = var.rediscache_sku_name
  rediscache_minimum_tls_version = var.rediscache_minimum_tls_version
  tags                           = var.tags
}


module "keyVault" {
  source                     = "./modules/keyVault"
  resource_group             = var.resource_group
  location                   = var.location
  keyvault_name              = var.keyvault_name
  soft_delete_retention_days = var.soft_delete_retention_days
  key_name                   = var.key_name
  key_type                   = var.key_type
  time_before_expiry         = var.time_before_expiry
  expire_after               = var.expire_after
  notify_before_expiry       = var.notify_before_expiry
  tags                       = var.tags
  sku_name                   = var.sku_name
  key_size                   = var.key_size
  secret_permissions         = var.secret_permissions
  key_opts                   = var.key_opts
  key_permissions            = var.key_permissions
  storage_permissions        = var.storage_permissions
  prefix = var.prefix
  env = var.env
}

module "function_app" {
  source                                     = "./modules/linuxfunctionapp"
  resource_group                             = var.resource_group
  location                                   = var.location
  linux_functionapp_name                     = var.linux_functionapp_name
  service_plan_name                          = var.service_plan_name
  linux_functionapp_minimum_tls_version      = var.linux_functionapp_minimum_tls_version
  linux_functionapp_remote_debugging_version = var.linux_functionapp_remote_debugging_version
  tags                                       = var.tags

  linux_function_app_network_region                  = var.linux_function_app_network_region
  linux_function_app_object                          = var.linux_function_app_object
  linux_function_app_service                         = var.linux_function_app_service
  linux_function_app_function                        = var.linux_function_app_function
  linux_function_app_lifecycle                       = var.linux_function_app_lifecycle
  linux_function_app_account_tier                    = var.linux_function_app_account_tier
  linux_function_app_account_replication_type        = var.linux_function_app_account_replication_type
  linux_function_app_os_type                         = var.linux_function_app_os_type
  linux_functionapp_always_on                        = var.linux_functionapp_always_on
  linux_functionapp_http2_enabled                    = var.linux_functionapp_http2_enabled
  linux_functionapp_load_balancing_mode              = var.linux_functionapp_load_balancing_mode
  linux_functionapp_managed_pipeline_mode            = var.linux_functionapp_managed_pipeline_mode
  linux_functionapp_remote_debugging_enabled         = var.linux_functionapp_remote_debugging_enabled
  linux_functionapp_ftps_state                       = var.linux_functionapp_ftps_state
  linux_functionapp_runtime_scale_monitoring_enabled = var.linux_functionapp_runtime_scale_monitoring_enabled
}

module "databrick" {
  source                      = "./modules/databrick"
  resource_group              = var.resource_group
  location                    = var.location
  workspace_name              = var.workspace_name
  workspace_sku               = var.workspace_sku
  tags                        = var.tags
  managed_resource_group_name = var.managed_resource_group_name
}

module "servicebus" {
  source                               = "./modules/servicebus"
  resource_group                       = var.resource_group
  location                             = var.location
  servicebus_namespace                 = var.servicebus_namespace
  servicebusqueue_name                 = var.servicebusqueue_name
  policy_name                          = var.policy_name
  max_size_in_megabytes                = var.max_size_in_megabytes
  max_delivery_count                   = var.max_delivery_count
  default_message_ttl                  = var.default_message_ttl
  lock_duration                        = var.lock_duration
  tags                                 = var.tags
  prefix                               = var.prefix
  policy_send                          = var.policy_send
  requires_duplicate_detection         = var.requires_duplicate_detection
  dead_lettering_on_message_expiration = var.dead_lettering_on_message_expiration
  requires_session                     = var.requires_session
  policy_listen                        = var.policy_listen
  service_bus_sku                                  = var.service_bus_sku
  enable_partitioning                  = var.enable_partitioning
  policy_manage                        = var.policy_manage
  env                                  = var.env
}


module "AzMonitor" {
  source              = "./modules/LogAnalyticsWorkspace"
  env                 = var.env
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  alert_scope_id      = var.resource_grp_id
  action_grp_member   = var.action_grp_member
}

module "PostgresSql" {
  source                     = "./modules/PostgresSQL"
  location                   = var.location
  resource_group_name        = var.resource_group
  tags                       = var.tags
  env                        = var.env
  prefix                     = var.prefix
  psql_sku                   = var.psql_sku
  eic_ip_list                = var.eic_ip_list
  psql_subnet_id             = module.vnet.subnet_id2
  log_analytics_workspace_id = module.AzMonitor.log_analytics_workspace_id
}
module "datalake" {
  source                = "./modules/datalake"
  env                   = var.env
  prefix                = var.prefix
  location              = var.location
  resource_group_name   = var.resource_group
  cool_account_tier     = var.cool_account_tier
  container_access_type = var.container_access_type
  cool_replication_type = var.cool_replication_type
  tags                  = var.tags
}

