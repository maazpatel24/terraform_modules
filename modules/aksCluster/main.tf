
#----------------------------------------------------
# Creates a User assigned Identity for AKS Cluster.
#----------------------------------------------------
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.env}${var.prefix}-${var.user_assigned_identity}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}
# data "azurerm_virtual_network" "vnet-01" {
#   name = "temp-vnet-01"
#   resource_group_name = "sa1_test_eic_AbhinavJha"
# }
# data "azurerm_subnet" "default" {
#   name                 = "default"
#   virtual_network_name = "temp-vnet-01"
#   resource_group_name  = "sa1_test_eic_AbhinavJha"
# }

#--------------------------
# Creates an AKS Cluster.
#--------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.env}${var.prefix}-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "${var.env}${var.prefix}-${var.cluster_name}"
  kubernetes_version  = var.aks_version
  sku_tier            = var.sku_tier

  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_enabled == false ? null : var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  # private_dns_zone                    = var.private_dns_zone

  #public_network_access_enabled = var.public_network_access_enabled

  role_based_access_control_enabled = var.role_based_access_control_enabled
  run_command_enabled               = var.run_command_enabled
  workload_identity_enabled         = var.workload_identity_enabled

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.aks_identity.id] : []
  }


  default_node_pool {
    name                 = var.default_node_pool.name
    node_count           = var.default_node_pool.node_count
    max_count            = var.default_node_pool.enable_auto_scaling == false ? null : var.default_node_pool.max_count
    min_count            = var.default_node_pool.enable_auto_scaling == false ? null : var.default_node_pool.min_count
    vm_size              = var.default_node_pool.vm_size
    type                 = var.default_node_pool.type
    #enable_auto_scaling  = var.default_node_pool.enable_auto_scaling
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    os_disk_type         = var.default_node_pool.os_disk_type
    os_sku               = var.default_node_pool.os_sku
    scale_down_mode      = var.default_node_pool.scale_down_mode
    ultra_ssd_enabled    = var.default_node_pool.ultra_ssd_enabled
    orchestrator_version = var.default_node_pool.orchestrator_version
    node_labels          = var.node_labels
    # vnet_subnet_id       = data.azurerm_subnet.default.id
  }

  tags = var.tags
}

#------------------------------------------------------------
# Creates multiple Additional Kubernetes Cluster Node Pool.
#-------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "additional_nodepool" {
  count                 = var.additional_nodepool.name != "" ? length(var.additional_nodepool.name) : 0
  name                  = var.additional_nodepool.name[count.index]
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.additional_nodepool.vm_size
  node_count            = var.additional_nodepool.node_count
  node_taints           = var.additional_nodepool.node_taints
  kubelet_disk_type     = var.additional_nodepool.kubelet_disk_type

  max_pods = var.additional_nodepool.max_pods
  mode     = var.additional_nodepool.mode

  orchestrator_version = var.additional_nodepool.orchestrator_version
  os_disk_size_gb      = var.additional_nodepool.os_disk_size_gb
  os_disk_type         = var.additional_nodepool.os_disk_type
  os_sku               = var.additional_nodepool.os_sku
  os_type              = var.additional_nodepool.os_type

  priority          = var.additional_nodepool.priority
  scale_down_mode   = var.additional_nodepool.scale_down_mode
  spot_max_price    = var.additional_nodepool.spot_max_price
  ultra_ssd_enabled = var.additional_nodepool.ultra_ssd_enabled

  node_labels = var.node_labels

  tags = var.tags
}