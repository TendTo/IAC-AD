# ===============================
# Required variables
# ===============================
variable "router_wireguard_port" {
  description = "Port to use for the wireguard server"
  type        = number

  validation {
    condition     = var.router_wireguard_port >= 80 && var.router_wireguard_port <= 65535
    error_message = "Ports must be between 80 and 65535"
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
  description = "ID of the network the subnet will be attached to"
  type        = string
}
variable "router_cidr" {
  description = "CIDR of the subnet to create. Meaning the range of IP addresses that will be available for the instances in the subnet."
  type        = string
}
variable "external_network_id" {
  description = "ID of the external network to attach the router to"
  type        = string
}
variable "vulnbox_cidr" {
  description = "CIDR of the vulnbox subnet. Used by the router to attach itself to the vulnbox subnet"
  type        = string
}
variable "vulnbox_count" {
  description = "Number of vulnbox instances to create"
  type        = number
}
