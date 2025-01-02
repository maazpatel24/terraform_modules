
#-------------------------
# Create Redis Cache
#-------------------------
resource "azurerm_redis_cache" "rediscache" {
  count               = length(var.redis_cache_name)
  name                = "${var.env}${var.prefix}-${var.redis_cache_name[count.index]}"
  location            = var.location
  resource_group_name = var.resource_group
  capacity            = var.rediscache_capacity
  family              = var.rediscache_family
  sku_name            = var.rediscache_sku_name
  #enable_non_ssl_port = var.rediscache_enable_non_ssl_port
  minimum_tls_version = var.rediscache_minimum_tls_version

  redis_configuration {}

  # tags = var.tags
}