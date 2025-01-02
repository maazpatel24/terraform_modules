output "workspace_id" {
  value       = azurerm_databricks_workspace.databrick_workspace[*].id
  description = "The ID of the created Azure Databricks workspace."
}
output "workspace_url" {
  value       = azurerm_databricks_workspace.databrick_workspace[*].workspace_url
  description = "The URL of the created Azure Databricks workspace."
}
