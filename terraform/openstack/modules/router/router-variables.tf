# ===============================
# Required variables
# ===============================
variable "public_ip" {
  description = "Public IP address of the router"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.public_ip))
    error_message = "The public IP address must be a valid IPv4 address"
  }
}
variable "router_flavor_name" {
  description = "Name of the flavor to use for the router. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
  type        = string
}
variable "router_image_id" {
  description = "ID of the image to use for the router. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
  type        = string
}
variable "network_id" {
  description = "ID of the network"
  type        = string
}
variable "router_subnet_id" {
  description = "ID of the subnet to use for the router"
  type        = string
}
variable "router_secgroup_id" {
  description = "ID of the security group to use for the router"
  type        = string
}
