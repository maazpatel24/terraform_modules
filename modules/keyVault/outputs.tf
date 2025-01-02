output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.keyvault.id
}
output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.keyvault.name
}
output "key_id" {
  description = "The ID of the Key."
  value       = azurerm_key_vault_key.keyvault_key[*].id
}
output "key_name" {
  description = "The name of the Key."
  value       = azurerm_key_vault_key.keyvault_key[*].name
}
// output "access_policy_id" {
//   description = "The ID of the Access Policy."
//   value       = azurerm_key_vault_access_policy.kvkuser.id
// }

# output "access_policy_id" {
#   description = "The ID of the Access Policy."
#   value       = azurerm_key_vault.kayvault.access_policy.id
# }