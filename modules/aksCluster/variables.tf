variable "location" {
  description = "The azure location to setup the cluster and related resources"
  type        = string
}
variable "env" {
  description = "Provide current environment name"
  type        = string
}
variable "prefix" {
  description = "Prefix to be added with all resources"
  type        = string
}
variable "resource_group" {
  description = "Name of the resource group"
  type        = string
}
variable "cluster_name" {
  description = "Name of AKS cluster"
  type        = string
}
variable "identity_type" {
  description = "The Type of Identity which should be used for this Disk Encryption Set."
  type        = string
}
variable "user_assigned_identity" {
  description = "The Name of the User Assigned Identity assigned to the Kubelets."
  type        = string
}
variable "aks_version" {
  description = "set varible to use specific version,insted of lattest one"
  type        = string
}
variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster."
  type        = string
}
variable "role_based_access_control_enabled" {
  description = "Whether Role Based Access Control for the Kubernetes Cluster should be enabled."
  type        = bool
}
variable "run_command_enabled" {
  description = "Whether to enable run command for the cluster or not."
  type        = bool
}
variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Kubernetes Cluster."
  type        = bool
}
variable "private_cluster_enabled" {
  description = "This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located."
  type        = bool
}
variable "private_dns_zone_id" {
  description = "Either the ID of Private DNS Zone which should be delegated to this Cluster, System to have AKS manage this or None."
  type        = string
}
# variable "private_dns_zone" {
#   description = "Testing purpose"
#   type = bool
#   default = true
# }
variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added."
  type        = bool
}
variable "image_cleaner_enabled" {
  description = "Specifies whether Image Cleaner is enabled."
  type        = bool
}
variable "image_cleaner_interval_hours" {
  description = "Specifies the interval in hours when images should be cleaned up."
  type        = number
}
variable "workload_identity_enabled" {
  description = "Specifies whether Azure AD Workload Identity should be enabled for the Cluster."
  type        = bool
}
variable "enable_auto_scaling" {
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool?"
  type        = bool
}
variable "default_node_pool" {
  description = "Creates a Default Node Pool with some basic parameters. ***NOTE:*** `max_count` and `min_count` must be set to `null` when `enable_auto_scaling` is set to `false`."
  type = object({
    name : string
    node_count : number
    min_count : number
    max_count : number
    vm_size : string
    type : string
    enable_auto_scaling : bool
    os_disk_size_gb : number
    os_disk_type : string
    os_sku : string
    scale_down_mode : string
    ultra_ssd_enabled : bool
    orchestrator_version : string
  })

  default = {
    name                 = "nodepool01"
    node_count           = 1
    min_count            = 1
    max_count            = 5
    vm_size              = "Standard_DS2_v2"
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = false
    os_disk_size_gb      = 128
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    scale_down_mode      = "Delete"
    ultra_ssd_enabled    = false
    orchestrator_version = "1.27.1"
    
  }
}
variable "additional_nodepool" {
  description = "Creates multiple additional Node Pools with various parameters."
  type = object({
    name : list(string)
    vm_size : string
    node_count : number
    node_taints : list(string)
    kubelet_disk_type : string
    max_pods : number
    mode : string
    orchestrator_version : string
    os_disk_size_gb : number
    os_disk_type : string
    os_sku : string
    os_type : string
    priority : string
    scale_down_mode : string
    spot_max_price : number
    ultra_ssd_enabled : bool
  })

  default = {
    name                 = []
    vm_size              = "Standard_DS2_v2"
    node_count           = 1
    node_taints          = ["EnbleRunOnGPUNode=Yes:PreferNoSchedule"]
    kubelet_disk_type    = "OS"
    max_pods             = 110
    mode                 = "User"
    orchestrator_version = "1.27.1"
    os_disk_size_gb      = 128
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    os_type              = "Linux"
    priority             = "Regular"
    scale_down_mode      = "Delete"
    spot_max_price       = -1
    ultra_ssd_enabled    = false

  }
}
variable "node_labels" {
  description = "A map of Kubernetes labels which should be applied to nodes in this Node Pool."
  type        = map(string)
}

variable "tags" {
  description = "List of the different tags"
  type        = map(string)
}
