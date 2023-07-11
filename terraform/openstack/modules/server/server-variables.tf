# ===============================
# Required variables
# ===============================
variable "server_flavor_name" {
  description = "Name of the flavor to use for the server. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
  type        = string
}
variable "server_image_id" {
  description = "ID of the image to use for the server. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
  type        = string
}
variable "network_id" {
  description = "ID of the network the subnet will be attached to"
  type        = string
}
variable "server_subnet_id" {
  description = "ID of the subnet to use for the server"
  type        = string
}
variable "server_secgroup_id" {
  description = "ID of the security group to use for the serveres"
  type        = string
}

