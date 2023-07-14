# ===============================
# Required variables
# ===============================
variable "resource_group_name" {
  description = "Name of the resource group to create the network in"
  type        = string
}
variable "location" {
  description = "Location of the resource group to create the network in"
  type        = string
}
variable "router_size" {
  description = "Name of the instance type to use for the router. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
  type        = string
}
variable "router_image" {
  description = "Virtual Machine source image information for the router."
  type        = map(string)
}
variable "router_subnet_id" {
  description = "ID of the subnet of the router."
  type        = string
}
variable "router_secgroup_id" {
  description = "ID of the security group to use for the router"
  type        = string
}
variable "router_app_secgroup_id" {
  description = "ID of the application security group to use for the router"
  type        = string
}
