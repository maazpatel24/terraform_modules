output "redis_client_password" {
  description = "Redis cache access key"
  value       = azurerm_redis_cache.rediscache[*].primary_access_key
  sensitive   = true
}
output "redis_client_name" {
  description = "Redis cache Name"
  value       = azurerm_redis_cache.rediscache[*].name
}