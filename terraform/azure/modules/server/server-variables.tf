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
variable "server_size" {
  description = "Name of the instance type to use for the server. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
  type        = string
}
variable "server_image" {
  description = "Virtual Machine source image information for the server."
  type        = map(string)
}
variable "server_subnet_id" {
  description = "ID of the subnet of the server."
  type        = string
}
variable "server_secgroup_id" {
  description = "ID of the security group to use for the server"
  type        = string
}
