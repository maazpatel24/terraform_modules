
#-----------------------------------
# Create ServiceBus Namespace
#-----------------------------------
resource "azurerm_servicebus_namespace" "servicebus" {
  location            = var.location
  name                = "${var.env}${var.prefix}-${var.servicebus_namespace}"
  resource_group_name = var.resource_group
  sku                 = var.service_bus_sku

  tags = var.tags
}

#------------------------------------
# Create ServiceBus Queue for Request
#------------------------------------
resource "azurerm_servicebus_queue" "servicebusqueue" {
  count                                = length(var.servicebusqueue_name)
  name                                 = "${var.env}${var.prefix}-${var.servicebusqueue_name[count.index]}"
  namespace_id                         = azurerm_servicebus_namespace.servicebus.id
  max_size_in_megabytes                = var.max_size_in_megabytes
  max_delivery_count                   = var.max_delivery_count
  default_message_ttl                  = var.default_message_ttl
  lock_duration                        = var.lock_duration
  requires_duplicate_detection         = var.requires_duplicate_detection
  # `~enable_partitioning                  = var.enable_partitioning
  dead_lettering_on_message_expiration = var.dead_lettering_on_message_expiration
  requires_session                     = var.requires_session
}

#----------------------------------------------
# Create ServiceBus Namespace Auth Rule to send
#----------------------------------------------
resource "azurerm_servicebus_namespace_authorization_rule" "policy" {
  count        = length(var.policy_name)
  name         = "${var.env}${var.prefix}-${var.policy_name[count.index]}"
  namespace_id = azurerm_servicebus_namespace.servicebus.id

  listen = var.policy_listen
  send   = var.policy_send
  manage = var.policy_manage
}