output "psql_admin_password" {
  value = random_password.psqlpassword.result
}
output "psql_dbuser_password" {
  value = random_password.new-psqldbpassword.result
}
# output "sql_connection_string_secret_name" {
#   value = azurerm_key_vault_secret.sql-connection-string.name
# }
#output "sql_connection_string" {
#  value = azurerm_key_vault_secret.sql-connection-string.value
#}
output "psql_server_id" {
  value = azurerm_postgresql_flexible_server.psql-server.id
}
output "psql_server_name" {
  value = azurerm_postgresql_flexible_server.psql-server.name
}
# output "sql_connection_string" {
#   value = azurerm_private_endpoint.psql-private-endpoint.private_service_connection
# }
output "postgres_database" {
  value = azurerm_postgresql_flexible_server_database.jci-database.name
}
output "postgres_host" {
  value = azurerm_postgresql_flexible_server.psql-server.fqdn
}
output "postgres_user" {
  value = azurerm_postgresql_flexible_server.psql-server.administrator_login
}
output "postgres_dbuser" {
  value = local.db_user
}