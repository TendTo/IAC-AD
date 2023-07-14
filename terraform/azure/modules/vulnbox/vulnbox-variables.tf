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
variable "vulnbox_secgroup_id" {
  description = "ID of the security group to use for the vulnboxes"
  type        = string
}
variable "team_id" {
  description = "ID of the team to which the vulnbox belongs. It is used to determine the subnet"
  type        = number

  validation {
    condition     = var.team_id > 0 && var.team_id < 254
    error_message = "Team ID must be between 1 and 253 (inclusive)"
  }
}
variable "vulnbox_size" {
  description = "Name of the instance type to use for the vulnboxes. It determins the instance's computing power. (m1.small, m1.medium, etc.)"
  type        = string
}
variable "vulnbox_image" {
  description = "Virtual Machine source image information for the vulnbox."
  type        = map(string)
}
variable "vulnbox_subnet_id" {
  description = "ID of the subnet to use for the vulnboxes"
  type        = string
}
