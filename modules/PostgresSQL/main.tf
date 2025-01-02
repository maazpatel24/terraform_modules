locals {
  db_user               = "${var.env}${var.prefix}user"
  # stripe_dump_file_path = "./modules/PostgresSQL/dataFiles/StripePricing-${var.env}.sql"
}

## Fetching Ip
data "http" "myip" {
  url = "https://ipinfo.io/json"
}

## Admin credentials
resource "random_password" "psqlpassword" {
  length  = 10
  special = true
}

## Database user credentials
resource "random_password" "new-psqldbpassword" {
  length  = 8
  special = false
}

## Creation of PostgreSQL server
resource "azurerm_postgresql_flexible_server" "psql-server" {
  name                   = lookup({ qa = "${var.env}${var.prefix}managementdb42" }, var.env, "${var.env}${var.prefix}managementdb01")
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  administrator_login    = "${var.prefix}sqladmin"
  administrator_password = random_password.psqlpassword.result
  zone                   = "1"
  tags                   = var.tags
  storage_mb             = 32768
  storage_tier           = "P30"
  sku_name               = var.psql_sku
}

## PostgreSQL Configuration
resource "azurerm_postgresql_flexible_server_configuration" "psql_conf" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.psql-server.id
  value     = "PGCRYPTO,POSTGIS,DBLINK,PG_CRON,DICT_XSYN,PG_BUFFERCACHE,pgaudit"
}

## Creation of PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "postgres-database" {
  name      = "${var.prefix}psqldb"
  server_id = azurerm_postgresql_flexible_server.psql-server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

## Creation of JCI database
resource "azurerm_postgresql_flexible_server_database" "jci-database" {
  name      = "jci550"
  server_id = azurerm_postgresql_flexible_server.psql-server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# ## PSQL Schema, BaseData, StripeData, AddressData restore and Function Creation
# resource "null_resource" "psql-restore" {
#   provisioner "local-exec" {
#     command = <<EOT
#       PGPASSWORD='${random_password.psqlpassword.result}' psql -f ${var.schema_dump_file_path} \
#         --dbname=${azurerm_postgresql_flexible_server_database.jci-database.name} \
#         --host=${azurerm_postgresql_flexible_server.psql-server.fqdn} \
#         --port=5432 \
#         --username=${azurerm_postgresql_flexible_server.psql-server.administrator_login} \

#       PGPASSWORD='${random_password.psqlpassword.result}' psql -f ${var.base_dump_file_path} \
#        --dbname=${azurerm_postgresql_flexible_server_database.jci-database.name} \
#        --host=${azurerm_postgresql_flexible_server.psql-server.fqdn} \
#        --port=5432 \
#        --username=${azurerm_postgresql_flexible_server.psql-server.administrator_login} \

#       PGPASSWORD='${random_password.psqlpassword.result}' psql -f ${local.stripe_dump_file_path} \
#        --dbname=${azurerm_postgresql_flexible_server_database.jci-database.name} \
#        --host=${azurerm_postgresql_flexible_server.psql-server.fqdn} \
#        --port=5432 \
#        --username=${azurerm_postgresql_flexible_server.psql-server.administrator_login} \
      
#       PGPASSWORD='${random_password.psqlpassword.result}' pg_restore -Fc \
#        --dbname=${azurerm_postgresql_flexible_server_database.jci-database.name} ${var.address_dump_file_path} \
#        --host=${azurerm_postgresql_flexible_server.psql-server.fqdn} \
#        --port=5432 \
#        --username=${azurerm_postgresql_flexible_server.psql-server.administrator_login} \
#     EOT
#   }
#   depends_on = [azurerm_postgresql_flexible_server_database.jci-database]
# }

# ## SQL queries to create a normal user for the database 
# resource "null_resource" "db-user" {
#   provisioner "local-exec" {
#     command = <<EOT
#       PGPASSWORD='${random_password.psqlpassword.result}' psql \
#         --host=${azurerm_postgresql_flexible_server.psql-server.fqdn} \
#         --port=5432 \
#         --username=${azurerm_postgresql_flexible_server.psql-server.administrator_login} \
#         --dbname=${azurerm_postgresql_flexible_server_database.jci-database.name} \
#         --command="DO \$\$
#                   BEGIN
#                       IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_user WHERE usename = '${local.db_user}') THEN
#                           CREATE USER ${local.db_user} WITH PASSWORD '${random_password.new-psqldbpassword.result}'; \
#                       END IF;
#                   END \$\$;
#                   GRANT CREATE ON SCHEMA public TO ${local.db_user}; \
#                   GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${local.db_user}; \
#                   GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ${local.db_user};"
#     EOT
#   }
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   depends_on = [null_resource.psql-restore]
# }

# ## Private endpoint for PostgreSQL Server
# resource "azurerm_private_endpoint" "psql-private-endpoint" {
#   name                = "${var.env}-${var.prefix}-psql-private-endpoint"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.psql_subnet_id
#   tags                = var.tags
#   private_service_connection {
#     name                           = format("%s-%s-psql-pe", var.env, var.prefix)
#     private_connection_resource_id = azurerm_postgresql_flexible_server.psql-server.id
#     subresource_names              = ["postgresqlServer"]
#     is_manual_connection           = false
#   }
#   private_dns_zone_group {
#     name                 = "${var.env}psql"
#     private_dns_zone_ids = [var.private_dnszone_id]
#   }
# }

# ## Set "A" name record for PostgreSQL Server
# resource "azurerm_private_dns_a_record" "psql-record" {
#   name                = azurerm_postgresql_flexible_server.psql-server.name
#   zone_name           = var.private_dnszone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.psql-private-endpoint.private_service_connection.0.private_ip_address]
# }

## Firewall rule for Azure DevOps pipeline agent
resource "azurerm_postgresql_flexible_server_firewall_rule" "psql-firewall-agent" {
  name             = "azure-agent-ip"
  server_id        = azurerm_postgresql_flexible_server.psql-server.id
  start_ip_address = jsondecode(data.http.myip.response_body).ip
  end_ip_address   = jsondecode(data.http.myip.response_body).ip
  depends_on       = [azurerm_postgresql_flexible_server.psql-server]
}

## Firewall rule for EIC Ips
resource "azurerm_postgresql_flexible_server_firewall_rule" "psql-firewall" {
  count            = length(var.eic_ip_list)
  name             = "${var.env}-${var.prefix}-psql-fw-eic${count.index}"
  server_id        = azurerm_postgresql_flexible_server.psql-server.id
  start_ip_address = cidrhost(var.eic_ip_list[count.index], 0)
  end_ip_address   = cidrhost(var.eic_ip_list[count.index], -1)
}

## PostgreSQL connection string
# resource "azurerm_key_vault_secret" "sql-connection-string" {
#   name         = "sql-connection-string-secret"
#   value        = "Server=${azurerm_private_dns_a_record.psql-record.fqdn};Database=${azurerm_postgresql_flexible_server_database.jci-database.name};Port=5432;User Id=${local.db_user};Password=${random_password.new-psqldbpassword.result};Ssl Mode=Require;"
#   key_vault_id = var.keyvault_id
#   lifecycle {
#     ignore_changes = [value, expiration_date]
#   }
#   expiration_date = timeadd(timestamp(), "${var.secret_expire_duration}h")
# }

# ## Key-vault Secret for Admin credentials
# resource "azurerm_key_vault_secret" "psql-secret" {
#   name            = "${azurerm_postgresql_flexible_server.psql-server.name}-secret"
#   value           = random_password.psqlpassword.result
#   key_vault_id    = var.keyvault_id
#   expiration_date = timeadd(timestamp(), "${var.secret_expire_duration}h")
#   lifecycle {
#     ignore_changes = [expiration_date]
#   }
# }

# ## Key-vault Secret for Database user credentials
# resource "azurerm_key_vault_secret" "new-psqldb-secret" {
#   name            = "psql-db-user"
#   value           = random_password.new-psqldbpassword.result
#   key_vault_id    = var.keyvault_id
#   expiration_date = timeadd(timestamp(), "${var.secret_expire_duration}h")
#   lifecycle {
#     ignore_changes = [expiration_date]
#   }
# }
