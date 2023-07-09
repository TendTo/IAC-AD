# ===============================
# Required variables
# ===============================
variable "server_instance_type" {
  description = "Name of the instance type to use for the server. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
  type        = string
}
variable "server_image_id" {
  description = "ID of the image to use for the server. This is usually the ID of an ami"
  type        = string
}
variable "server_subnet_id" {
  description = "ID of the subnet of the server."
  type        = string
}
variable "server_secgroup_id" {
  description = "ID of the security group to use for the server"
  type        = string
}
