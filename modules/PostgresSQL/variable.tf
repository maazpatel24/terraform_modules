variable "env" {}
variable "prefix" {}
variable "location" {}
variable "resource_group_name" {}
# variable "private_dnszone_id" {}
# variable "private_dnszone_name" {}
variable "psql_subnet_id" {}
variable "psql_sku" {}
variable "tags" {}
# variable "keyvault_id" {}
variable "eic_ip_list" {}
variable "log_analytics_workspace_id" {}
# variable "secret_expire_duration" {}
variable "server_parameter_list" {
  default = {
    "log_checkpoints" = "ON",
    "log_duration" = "ON",
    "pgaudit.log" = "DDL",
    "shared_preload_libraries" = "pgaudit",
    "connection_throttle.enable" = "ON"
    "logfiles.retention_days"  = "5"
  }
}

## SQL iles
variable "schema_dump_file_path" {
  description = "DevC550 database schema dump file path."
  default     = "./modules/PostgresSQL/dataFiles/Schema.sql"
}
variable "base_dump_file_path" {
  description = "Default data file path."
  default     = "./modules/PostgresSQL/dataFiles/BaseData.sql"
}
variable "address_dump_file_path" {
  description = "Address table and data creation file path."
  default     = "./modules/PostgresSQL/dataFiles/AddressData.sql"
}