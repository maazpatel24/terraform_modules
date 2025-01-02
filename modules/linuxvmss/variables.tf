variable "location" {
}
variable "resource_group" {
}
variable "prefix" {

}
variable "env" {

}
variable "tags" {

}
variable "vm_size" {

}
variable "linux_subnet_id" {

}
variable "admin_username" {

}
variable "public_key" {


}
variable "delete_os_disk_on_termination" {

}
variable "os_disk_type" {
}
variable "instances_count" {

}
variable "os_upgrade_mode" {

}
variable "vmss_max_batch_instance_percent" {
}
variable "vmss_max_unhealthy_instance_percent" {

}
variable "vmss_max_unhealthy_upgraded_instance_percent" {

}
variable "vmss_pause_time_between_batches" {

}

## Autoscaling Variables for VMSS ##

variable "minimum_instances_count" {

}
variable "maximum_instances_count" {

}
variable "scaling_action_instances_number" {
}
variable "increase_metric_name" {

}
variable "increase_operator" {
}
variable "increase_statistic" {
}
variable "increase_threshold" {
}
variable "increase_time_aggregation" {

}
variable "increase_time_grain" {

}
variable "increase_time_window" {
}
variable "scaling_action_cooldown" {
}
variable "decrease_metric_name" {

}
variable "decrease_operator" {

}
variable "decrease_statistic" {

}
variable "decrease_threshold" {
  description = "Specifies the threshold of the metric that triggers the scale action for scale down"
  type        = number
  default     = 20
}
variable "decrease_time_aggregation" {

}
variable "decrease_time_grain" {

}
variable "decrease_time_window" {

}
variable "publicip" {

}

variable "vmss_name" {

}

variable "publisher" {

}
variable "sku" {

}
variable "sku_version" {

}