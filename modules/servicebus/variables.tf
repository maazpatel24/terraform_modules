variable "location" {
  description = "The location(region) where the resources will be created"
  type        = string
  # default     = "southeastasia"
}
variable "env" {
  description = "provide current environment name"
  type        = string
  # default     = "dev"
}
variable "prefix" {
  description = "Prefix to be added with all resources"
  type        = string
  # default     = "eic"
}
variable "resource_group" {
  # description = "Default resource group name in which resources will be launch."
  type        = string
  default     = "eic-portal-dev-rg"
}
variable "servicebus_namespace" {
  description = "value"
  type        = string
  # default     = "serviceBusNS"
}
variable "servicebusqueue_name" {
  description = "Service bus queue name"
  type        = list(string)
  # default     = ["servicebusqueuerequest", "servicebusqueueresponse"]
}
variable "policy_name" {
  description = "Service bus policy name"
  type        = list(string)
  # default     = ["SendPolicy", "listenpolicy"]
}
variable "service_bus_sku" {
  description = "Defines which tier to use."
  type        = string
  # default     = "Standard"
}
variable "max_size_in_megabytes" {
  description = "Integer value which controls the size of memory allocated for the queue."
  type        = number
  # default     = 1024
}
variable "max_delivery_count" {
  description = "Integer value which controls when a message is automatically dead lettered."
  type        = number
  # default     = 10
}
variable "default_message_ttl" {
  description = "The ISO 8601 timespan duration of the TTL of messages sent to this queue"
  type        = string
  # default     = "P14D"
}
variable "lock_duration" {
  description = "The ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers"
  type        = string
  # default     = "PT30S"
}
variable "requires_duplicate_detection" {
  description = "Boolean flag which controls whether the Queue requires duplicate detection"
  type        = bool
  # default     = false
}
variable "enable_partitioning" {
  description = "Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers"
  type        = bool
  # default     = false
}
variable "dead_lettering_on_message_expiration" {
  description = "Boolean flag which controls whether the Queue has dead letter support when a message expires"
  type        = bool
  # default     = false
}
variable "requires_session" {
  description = "Boolean flag which controls whether the Queue requires sessions"
  type        = bool
  # default     = false
}
variable "policy_listen" {
  description = "Grants listen access to this this Authorization Rule."
  type        = bool
  # default     = true
}
variable "policy_send" {
  description = "Grants send access to this this Authorization Rule."
  type        = bool
  # default     = false
}
variable "policy_manage" {
  description = "Grants manage access to this this Authorization Rule."
  type        = bool
  # default     = false
}
variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
}