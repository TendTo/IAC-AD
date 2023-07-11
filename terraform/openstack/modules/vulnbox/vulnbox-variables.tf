# ===============================
# Required variables
# ===============================
variable "team_id" {
  description = "ID of the team to which the vulnbox belongs. It is used to determine the subnet"
  type        = number

  validation {
    condition     = var.team_id > 0 && var.team_id < 254
    error_message = "Team ID must be between 1 and 253 (inclusive)"
  }
}
variable "vulnbox_flavor_name" {
  description = "Name of the flavor to use for the vulnboxes. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
  type        = string
}
variable "vulnbox_image_id" {
  description = "ID of the image to use for the vulnboxes. This is usually the ID of a snapshot (Ubuntu 20.04, CentOS 8, etc.)"
  type        = string
}
variable "network_id" {
  description = "ID of the network the subnet will be attached to"
  type        = string
}
variable "vulnbox_subnet_id" {
  description = "ID of the subnet to use for the vulnboxes"
  type        = string
}
variable "vulnbox_secgroup_id" {
  description = "ID of the security group to use for the vulnboxes"
  type        = string
}

