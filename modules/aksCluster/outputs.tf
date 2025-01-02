output "cluster_id" {
  description = "ID of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}
output "cluster_name" {
  description = "Name of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}
output "nodepool_id" {
  description = "ID of the NodePool."
  value       = azurerm_kubernetes_cluster_node_pool.additional_nodepool[*].id
}