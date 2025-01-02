<!-- BEGIN_TF_DOCS -->
## Introduction

This module creates a simple AKS Cluster without any DiskEncryption-Set.

AKS Cluster is a Kubernetes cluster, which is created on the Azure Kubernetes Platform by Microsoft, that is one of the leading managed Kubernetes services.


## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional_nodepool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_user_assigned_identity.aks_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_nodepool"></a> [additional\_nodepool](#input\_additional\_nodepool) | Creates multiple additional Node Pools with various parameters. ***NOTE:*** If no `additional node pool` is required, the value of the `name` parameter should be set to `[]`. No additional node pool will be created by default.| <pre>object({<br>    name : list(string)<br>    vm_size : string<br>    node_count : number<br>    node_taints : list(string)<br>    kubelet_disk_type : string<br>    max_pods : number<br>    mode : string<br>    orchestrator_version : string<br>    os_disk_size_gb : number<br>    os_disk_type : string<br>    os_sku : string<br>    os_type : string<br>    priority : string<br>    scale_down_mode : string<br>    spot_max_price : number<br>    ultra_ssd_enabled : bool<br>  })</pre> | <pre>{<br>  "kubelet_disk_type": "OS",<br>  "max_pods": 110,<br>  "mode": "User",<br>  "name": [],<br>  "node_count": 1,<br>  "node_taints": [<br>    "EnbleRunOnGPUNode=Yes:PreferNoSchedule"<br>  ],<br>  "orchestrator_version": "1.27.1",<br>  "os_disk_size_gb": 128,<br>  "os_disk_type": "Managed",<br>  "os_sku": "Ubuntu",<br>  "os_type": "Linux",<br>  "priority": "Regular",<br>  "scale_down_mode": "Delete",<br>  "spot_max_price": -1,<br>  "ultra_ssd_enabled": false,<br>  "vm_size": "Standard_DS2_v2"<br>}</pre> | no |
| <a name="input_aks_version"></a> [aks\_version](#input\_aks\_version) | set varible to use specific version,insted of lattest one | `string` | `"1.27.1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of AKS cluster | `string` | `"cluster01"` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Creates a Default Node Pool with some basic parameters. ***NOTE:*** If the `auto_scaling_enabled` parameter is set to `false`, the `max_count` and `min_count` parameters will have a default value of `null`.  | <pre>object({<br>    name : string<br>    node_count : number<br>    min_count : number<br>    max_count : number<br>    vm_size : string<br>    type : string<br>    enable_auto_scaling : bool<br>    os_disk_size_gb : number<br>    os_disk_type : string<br>    os_sku : string<br>    scale_down_mode : string<br>    ultra_ssd_enabled : bool<br>    orchestrator_version : string<br>  })</pre> | <pre>{<br>  "enable_auto_scaling": false,<br>  "max_count": 5,<br>  "min_count": 1,<br>  "name": "nodepool01",<br>  "node_count": 1,<br>  "orchestrator_version": "1.27.1",<br>  "os_disk_size_gb": 128,<br>  "os_disk_type": "Managed",<br>  "os_sku": "Ubuntu",<br>  "scale_down_mode": "Delete",<br>  "type": "VirtualMachineScaleSets",<br>  "ultra_ssd_enabled": false,<br>  "vm_size": "Standard_D8_v5"<br>}</pre> | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Should the Kubernetes Auto Scaler be enabled for this Node Pool? | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Provide current environment name | `string` | `"dev"` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Type of Identity which should be used for this Disk Encryption Set. | `string` | `"UserAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | Specifies whether Image Cleaner is enabled. | `bool` | `false` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | Specifies the interval in hours when images should be cleaned up. | `number` | `48` | no |
| <a name="input_location"></a> [location](#input\_location) | The azure location to setup the cluster and related resources | `string` | `"eastus"` | no |
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels) | A map of Kubernetes labels which should be applied to nodes in this Node Pool. | `map(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to be added with all resources | `string` | `"eic"` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Specifies whether a Public FQDN for this Private Cluster should be added. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Either the ID of Private DNS Zone which should be delegated to this Cluster, System to have AKS manage this or None. | `string` | `"None"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for this Kubernetes Cluster. | `bool` | `true` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Name of the resource group | `string` | `"eic-portal-dev-rg"` | no |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Whether Role Based Access Control for the Kubernetes Cluster should be enabled. | `bool` | `true` | no |
| <a name="input_run_command_enabled"></a> [run\_command\_enabled](#input\_run\_command\_enabled) | Whether to enable run command for the cluster or not. | `bool` | `true` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of the different tags. | `map(string)` | n/a | yes |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | The Name of the User Assigned Identity assigned to the Kubelets. | `string` | `"clusterID01"` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Specifies whether Azure AD Workload Identity should be enabled for the Cluster. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the AKS Cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS Cluster |
| <a name="output_nodepool_id"></a> [nodepool\_id](#output\_nodepool\_id) | ID of the NodePool. |
<!-- END_TF_DOCS -->