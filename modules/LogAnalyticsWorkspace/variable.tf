variable "resource_group_name" {}
variable "location" {
}
variable "env" {}
variable "tags" {}
variable "prefix" {}

## Action Group
variable "action_grp_member" {
  description = "Member IDs of Action Group."
}

## Alert rules
variable "alert_scope_id" {
  description = "The Scope at which the Activity Log should be applied. A list of strings which could be a resource group , or a subscription, or a resource ID (such as a Storage Account)."
}
