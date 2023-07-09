# ===============================
# Required variables
# ===============================
variable "router_instance_type" {
  description = "Name of the instance type to use for the router. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
  type        = string
}
variable "router_image_id" {
  description = "ID of the image to use for the router. This is usually the ID of an ami"
  type        = string
}
variable "router_subnet_id" {
  description = "ID of the subnet of the router."
  type        = string
}
variable "router_secgroup_id" {
  description = "ID of the security group to use for the router"
  type        = string
}
