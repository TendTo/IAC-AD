# ===============================
# Required variables
# ===============================
variable "vulnbox_service_ports" {
  description = "List of ports to open on the vulnbox instances, so that the vulnerable services are accessible"
  type        = set(number)

  validation {
    condition     = length(var.vulnbox_service_ports) > 0
    error_message = "At least one port must be specified"
  }

  validation {
    condition     = alltrue([for port in var.vulnbox_service_ports : port >= 80 && port <= 65535])
    error_message = "Ports must be between 80 and 65535"
  }
}
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
variable "subnet_cidr" {
  description = "CIDR of the subnet to create. Meaning the range of IP addresses that will be available for the instances in the subnet."
  type        = string
}

