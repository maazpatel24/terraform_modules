
#//#Common
variable "env" {}
variable "prefix" {}
variable "location" {}
variable "resource_group" {}
variable "tags" {}
variable "subscription_id" {}

###ssh_key
variable "file_name" {}
variable "algorithm" {}

###vnet
variable "vnet_name" {}
variable "net_range" {}
variable "subnet_name" {}
variable "subnet_range" {}

###nsg
variable "network_security_group_name" {}


###linuxvm
variable "public_ip_name" {}
variable "allocation_method" {}
variable "private_ip_address_allocation_method" {}
variable "key_data" {}
variable "vm_name" {}
variable "vm_size" {}
variable "nic_name" {}
variable "linux_publisher" {}
variable "linux_offer" {}
variable "linux_sku" {}
variable "linux_sku_version" {}
variable "admin_username" {}
variable "caching" {}
variable "managed_disk_type" {}

###vmss

variable "vmss_name" {}
variable "os_disk_type" {}
variable "delete_os_disk_on_termination" {}
variable "instances_count" {}
variable "os_upgrade_mode" {}
variable "vmss_max_batch_instance_percent" {}
variable "vmss_max_unhealthy_instance_percent" {}
variable "vmss_max_unhealthy_upgraded_instance_percent" {}
variable "vmss_pause_time_between_batches" {}
variable "minimum_instances_count" {}
variable "maximum_instances_count" {}
variable "scaling_action_instances_number" {}
variable "increase_metric_name" {}
variable "increase_operator" {}
variable "increase_statistic" {}
variable "increase_time_aggregation" {}
variable "increase_time_grain" {}
variable "increase_time_window" {}
variable "scaling_action_cooldown" {}
variable "decrease_metric_name" {}
variable "decrease_operator" {}
variable "decrease_statistic" {}
variable "decrease_time_aggregation" {}
variable "decrease_time_grain" {}
variable "decrease_time_window" {}
variable "increase_threshold" {}
variable "decrease_threshold" {}
variable "publicip" {}
variable "publisher" {}
variable "sku" {}
variable "sku_version" {}

###acr 
variable "acr_sku" {}

###aks
variable "cluster_name" {}
variable "node_labels" {}
variable "identity_type" {}
variable "user_assigned_identity" {}
variable "aks_version" {}
variable "sku_tier" {}
variable "role_based_access_control_enabled" {}
variable "run_command_enabled" {}
variable "public_network_access_enabled" {}
variable "private_cluster_enabled" {}
variable "private_dns_zone_id" {}
variable "private_cluster_public_fqdn_enabled" {}
variable "image_cleaner_enabled" {}
variable "image_cleaner_interval_hours" {}
variable "workload_identity_enabled" {}
variable "enable_auto_scaling" {}

###eventhub
variable "eventhub_namespace_name" {}
variable "eventhub_name" {}
variable "eventhub_sku" {}
variable "capacity" {}
variable "partition_count" {}
variable "message_retention" {}

###iothub
variable "iothub_name" {}
variable "iothub_sku" {}

###Storage Account
variable "storage_account_name" {}
variable "tier" {}
variable "replication_type" {}
variable "container_name" {}
variable "table_name" {}
variable "queue_name" {}
variable "file_share_name" {}
#variable "container_access_type" {}
variable "quota" {}

###rediscache
variable "redis_cache_name" {}
variable "rediscache_capacity" {}
variable "rediscache_family" {}
variable "rediscache_enable_non_ssl_port" {}
variable "rediscache_sku_name" {}
variable "rediscache_minimum_tls_version" {}

###keyvault
variable "keyvault_name" {}
variable "soft_delete_retention_days" {}
variable "key_name" {}
variable "key_type" {}
variable "time_before_expiry" {}
variable "expire_after" {}
variable "notify_before_expiry" {}
variable "sku_name" {}
variable "key_size" {}
variable "secret_permissions" {}
variable "key_opts" {}
variable "key_permissions" {}
variable "storage_permissions" {}



###functionapp
variable "linux_functionapp_name" {}
variable "service_plan_name" {}
variable "linux_functionapp_minimum_tls_version" {}
variable "linux_functionapp_remote_debugging_version" {}
variable "linux_function_app_network_region" {}
variable "linux_function_app_object" {}
variable "linux_function_app_service" {}
variable "linux_function_app_function" {}
variable "linux_function_app_lifecycle" {}
variable "linux_function_app_account_tier" {}
variable "linux_function_app_account_replication_type" {}
variable "linux_function_app_os_type" {}
variable "linux_function_app_sku_name" {}
variable "linux_functionapp_always_on" {}
variable "linux_functionapp_http2_enabled" {}
variable "linux_functionapp_load_balancing_mode" {}
variable "linux_functionapp_managed_pipeline_mode" {}
variable "linux_functionapp_remote_debugging_enabled" {}
variable "linux_functionapp_ftps_state" {}
variable "linux_functionapp_runtime_scale_monitoring_enabled" {}





###databrick
variable "workspace_name" {}
variable "workspace_sku" {}
variable "managed_resource_group_name" {}


###servicebus
variable "servicebusqueue_name" {}
variable "policy_name" {}
variable "max_size_in_megabytes" {}
variable "max_delivery_count" {}
variable "default_message_ttl" {}
variable "servicebus_namespace" {}
variable "requires_duplicate_detection" {}
variable "enable_partitioning" {}
variable "dead_lettering_on_message_expiration" {}
variable "requires_session" {}
variable "policy_listen" {}
variable "policy_send" {}
variable "policy_manage" {}
variable "lock_duration" {}
variable "service_bus_sku" {}

#//#PostgressSQL
variable "psql_sku" {}
variable "eic_ip_list" {}


#//#Loganalytics
variable "resource_grp_id" {}
variable "action_grp_member" {}


#//# Data_lake_storage
variable "cool_replication_type" {}
variable "cool_account_tier" {}
variable "container_access_type" {}

