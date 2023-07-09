# ===============================
# Required variables
# ===============================
variable "iac_ad_external_network_id" {
  type        = string
  description = "ID of the external network to connect to, used to access the internet"
}
variable "iac_ad_vulnbox_image_id" {
  type        = string
  description = "ID of the image to use for the vulnboxes. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
}
variable "iac_ad_vulnbox_flavor_name" {
  type        = string
  description = "Name of the flavor to use for the vulnboxes. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
}
# variable "iac_ad_game_system_image_id" {
#   type        = string
#   description = "ID of the image to use for the game system. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
# }
# variable "iac_ad_game_system_flavor_name" {
#   type        = string
#   description = "Name of the flavor to use for the game system. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
# }
variable "iac_ad_router_image_id" {
  type        = string
  description = "ID of the image to use for the router. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
}
variable "iac_ad_router_flavor_name" {
  type        = string
  description = "Name of the flavor to use for the router. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
}
# ===============================
# Terraform optional variables
# ===============================
variable "iac_ad_cloud" {
  type        = string
  description = "Cloud credentials to use for the openstack authentication. It should be specified in ~/.config/openstack/clouds.yaml"
  default     = ""
}
variable "iac_ad_vulnbox_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create for the vulnboxes. Meaning the range of IP addresses that will be available for the instances in the subnet."
  default     = "10.60.%d.%d/24"
  validation {
    condition     = can(regex("[0-9]{1,3}\\.[0-9]{1,3}\\.%d\\.%d/[1-3]?[0-9]", var.iac_ad_vulnbox_subnet_cidr))
    error_message = "The vulnbox subnet CIDR must be in the format X.X.%d.%d/m, where X is a number between 0 and 255 and m is a number between 0 and 32"
  }
}
variable "iac_ad_router_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create for the router. Meaning the range of IP addresses that will be available for the instances in the subnet."
  default     = "10.10.0.%d/24"
  validation {
    condition     = can(regex("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.%d/[1-3]?[0-9]", var.iac_ad_router_subnet_cidr))
    error_message = "The router subnet CIDR must be in the format X.X.X.%d/m, where X is a number between 0 and 255 and m is a number between 0 and 32"
  }
}
variable "iac_ad_wireguard_port" {
  type        = number
  description = "Port to use for the wireguard server"
  default     = 51820
}
variable "vulnbox_count" {
  description = "Number of vulnboxes to create"
  type        = number
  default     = 1
}
