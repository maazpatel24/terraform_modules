#common
env             = "dev"
prefix          = "eic"
location        = "southeastasia"
resource_group  = "sa1_test_eic_AbhinavJha"
subscription_id = "664b6097-19f2-42a3-be95-a4a6b4069f6b"
tags = {
  "Delivery Manager" = "Shahid Raza"
  "Project Name "    = "Eic internal"
  "Business Unit"    = "PES"
}

### ssh_key
file_name       = "ssh_key_file"
algorithm = "RSA"

##vnet
vnet_name       = "temp-vnet-02"
net_range       = ["10.0.0.0/16"]
subnet_name     = ["default","private-subnet"]
subnet_range    = ["10.0.0.0/24","10.0.1.0/24"]

###nsg
network_security_group_name = "drupal"

#linuxvm
vm_name        = ["linuxvm01"]
vm_size        = "Standard_B2ms"
nic_name       = ["linuxnic01"]
allocation_method = "Static"
private_ip_address_allocation_method = "Dynamic"
linux_offer    = "0001-com-ubuntu-server-focal"
linux_publisher   = "Canonical"
caching           = "ReadWrite"
linux_sku      = "20_04-lts-gen2"
public_ip_name = ["public_ip01"]
linux_sku_version = "20.04.202209200"
managed_disk_type = "StandardSSD_LRS"
key_data       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEh9csY6EZgcricNp7OU2KBSKJYgypH0ociqFUIRwyhI0AvgKKgS0EjjQsRypwgu4d43goR4j4W2oWL/fQeCgnOtOSzjt/hSTG/XqH/l+kvhIfLu0PG52WTBlvusUSte5ALRIGSJXMsOtXQ1UQKHlP808TVBMu4T9wwdcOTGl1DRRDl34dA3EanZ9vEFJNo/TGtml7uXYfUIu73aHjC7uZx4gaUVCiRO3FpwUZPr4olQEBbMieX9YKiHWU0hq4lfqHXBY3bIvkjMfIXhFmlkQydJnG9++MGL93RieHQc2RakTj54Fz/JQHXByXSQIgdcY+GB5zipG+TKDAF6ul75sLeRWAUzNwUXR/SfNDW/KJeSQC/svYY4KpMDr/Wg/mQzUsc1GRTPc0S5CB6H8rKBm4AwKftkXB5XExtIoDoTlWahw/UYvR1QCmhCt/4IqA6oDCYJzv19ffYtB/3nkSaNQnueSNJzeayD0MCn1O1Gd3n7Ou6GlNGrZT7z9rGJhG1+k= abhinavjha102@gmail.com"
admin_username = "eicadmin"

###vmss

vmss_name               = "linuxvmss"
os_disk_type            = "Standard_LRS"
delete_os_disk_on_termination = "false"
os_upgrade_mode         = "Automatic"
vmss_max_batch_instance_percent = 20
vmss_max_unhealthy_instance_percent = 20
vmss_max_unhealthy_upgraded_instance_percent = 20
vmss_pause_time_between_batches = "PT0S"
scaling_action_instances_number = "1"
increase_metric_name = "Percentage CPU"
increase_operator = "GreaterThan"
increase_statistic = "Average"
instances_count         = 2
minimum_instances_count = 2
maximum_instances_count = 4
increase_threshold      = 80
decrease_threshold      = 20
increase_time_aggregation = "Average"
increase_time_grain     = "PT1M"
increase_time_window    = "PT5M"
scaling_action_cooldown = "PT1M"
decrease_metric_name = "Percentage CPU"
decrease_operator     =  "LessThan"
decrease_statistic = "Average"
decrease_time_aggregation = "Average"
decrease_time_grain = "PT1M"
decrease_time_window = "PT5M"
publicip = "publicip01"
publisher      = "Canonical"
sku                     = "20_04-lts-gen2"
sku_version             = "20.04.202209200"



### acr
acr_sku = "Basic"

###aksCluster
cluster_name = "cluster01" 
aks_version  = "1.29.9"
node_labels  = {
    "environment" = "TEST"
    "app"         = "web-server"
    "tier"        = "frontend"
    "team"        = "devops"
  }
identity_type = "UserAssigned"
user_assigned_identity = "clusterID01"
sku_tier = "Free"
role_based_access_control_enabled = true
run_command_enabled = true
public_network_access_enabled = true
private_cluster_enabled = true
private_dns_zone_id = "None"
private_cluster_public_fqdn_enabled = true
image_cleaner_enabled = false
image_cleaner_interval_hours = 48
workload_identity_enabled = false
enable_auto_scaling = false

###eventhub
eventhub_namespace_name = "eictesteventhubnamespace"
eventhub_name           = ["eic_eventhub_name01", "eic_eventhub_name02"]
eventhub_sku            = "Standard"
capacity                = 1
partition_count         = 2
message_retention       = 1

###iothub
iothub_name = ["eiciothub"]
iothub_sku  = "B1"


###storage Account
storage_account_name = "teststorage0176565"
tier                 = "Standard"
replication_type     = "LRS"
container_name       = ["testuniqcontainer76"]
table_name           = ["mytestqtable"]
queue_name           = ["testqueforcheck"]
file_share_name      = ["randomtestfileshar"]
#container_access_type = "private"
quota                 = 50

###rediscache
redis_cache_name               = ["rediscache01", "rediscache02"]
rediscache_capacity            = 2
rediscache_family              = "C"
rediscache_enable_non_ssl_port = false
rediscache_sku_name            = "Standard"
rediscache_minimum_tls_version = "1.2"

###Keyvault
keyvault_name              = "keyVault0105631"
soft_delete_retention_days = 90
key_name                   = ["key0118"]
key_type                   = "RSA"
time_before_expiry         = "P30D"
expire_after               = "P90D"
notify_before_expiry       = "P30D"
sku_name                   = "standard"
key_size                   = "2048"
secret_permissions         = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
key_opts                   = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
key_permissions            = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
    "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge", "GetRotationPolicy", "SetRotationPolicy"
  ]
storage_permissions        = ["Get", "List", "Update"]



###functionapp
linux_functionapp_name = ["linuxfunctionapp"]
service_plan_name = ["linux_service_plan01"]
linux_functionapp_minimum_tls_version = "1.2"
linux_functionapp_remote_debugging_version = "VS2022"
linux_function_app_network_region = "sa1"
linux_function_app_sku_name = "Y1"
linux_function_app_object = ["salinux", "lsp", "lfa"]
linux_function_app_service = "ma"
linux_function_app_function = "wb"
linux_function_app_lifecycle = "d"
linux_function_app_account_tier = "Standard"
linux_function_app_account_replication_type = "LRS"
linux_function_app_os_type = "Linux"
linux_functionapp_always_on = false
linux_functionapp_http2_enabled = false
linux_functionapp_load_balancing_mode = "LeastRequests"
linux_functionapp_managed_pipeline_mode = "Integrated"
linux_functionapp_remote_debugging_enabled = true
linux_functionapp_ftps_state = "Disabled"
linux_functionapp_runtime_scale_monitoring_enabled = false

###databrick
workspace_name = ["databricks-workspace001", "databrick-workspace002"]
workspace_sku = "standard"
managed_resource_group_name = ["res01", "res02"]

###servicebus
servicebus_namespace = "serviceBusNS"
servicebusqueue_name = ["servicebusqueuerequest", "servicebusqueueresponse"]
policy_name = ["SendPolicy", "listenpolicy"]
max_size_in_megabytes = 1024
max_delivery_count = 10
default_message_ttl = "P14D"
lock_duration = "PT30S"
service_bus_sku = "Standard"

resource_    = "eic-portal-dev-rg"
requires_duplicate_detection  = false
enable_partitioning  = false
dead_lettering_on_message_expiration  = false
requires_session  = false
policy_listen  = true
policy_send = false
policy_manage = false


eic_ip_list       = ["182.76.141.104/29", "115.112.142.32/29", "14.97.73.248/29"]
action_grp_member = ["abhinav.jha@einfochips.com"]


### Storage
cool_replication_type = "LRS"
cool_account_tier     = "Standard"
container_access_type = "private"
cool_container_name   = "devicemessages"

###psql
psql_sku = "B_Standard_B1ms"



###AzMonitor

resource_grp_id = "/subscriptions/664b6097-19f2-42a3-be95-a4a6b4069f6b/resourceGroups/sa1_test_eic_AbhinavJha"
//resource_grp_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}"