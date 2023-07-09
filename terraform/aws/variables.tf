# ===============================
# Required variables
# ===============================
variable "iac_ad_vulnbox_image_id" {
  type        = string
  description = "ID of the image to use for the vulnboxes. This is usually the ID of an ami"
}
variable "iac_ad_vulnbox_instance_type" {
  type        = string
  description = "Name of the instance type to use for the vulnboxes. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
}
variable "iac_ad_server_image_id" {
  type        = string
  description = "ID of the image to use for the game system. This is usually the ID of an ami"
}
variable "iac_ad_server_instance_type" {
  type        = string
  description = "Name of the instance type to use for the game system. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
}
variable "iac_ad_router_image_id" {
  type        = string
  description = "ID of the image to use for the router. This is usually the ID of an ami"
}
variable "iac_ad_router_instance_type" {
  type        = string
  description = "Name of the instance type to use for the router. It determins the instance's computing power. (t2.small, t2.medium, etc.)"
}
# ===============================
# Terraform optional variables
# ===============================
variable "iac_ad_aws_region" {
  type        = string
  description = "AWS region to use for the openstack authentication"
  default     = "us-east-1"
}
variable "iac_ad_aws_credentials_file" {
  type        = string
  description = "Path to the aws credentials file"
  default     = "~/.aws/credentials"
}
variable "iac_ad_aws_profile" {
  type        = string
  description = "AWS profile to use for the openstack authentication. It should be specified in aws credentials file"
  default     = "default"
}
variable "iac_ad_network_cidr" {
  type        = string
  description = "CIDR of the VPC to create. Meaning the range of IP addresses that will be available for the instances in the VPC."
  default     = "192.168.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.iac_ad_network_cidr))
    error_message = "Must be a valid ip address with mask"
  }
}
variable "iac_ad_router_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create for the router. Meaning the range of IP addresses that will be available for the instances in the subnet."
  default     = "192.168.0.0/24"
  validation {
    condition     = can(cidrnetmask(var.iac_ad_router_subnet_cidr))
    error_message = "Must be a valid ip address with mask"
  }
}
variable "iac_ad_server_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create for the game system. Meaning the range of IP addresses that will be available for the instances in the subnet."
  default     = "192.168.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.iac_ad_server_subnet_cidr))
    error_message = "Must be a valid ip address with mask"
  }
}
variable "iac_ad_vulnbox_subnet_cidr" {
  type        = string
  description = "CIDR of the subnet to create for the vulnboxes. Meaning the range of IP addresses that will be available for the instances in the subnet."
  default     = "192.168.2.0/24"
  validation {
    condition     = can(cidrnetmask(var.iac_ad_vulnbox_subnet_cidr))
    error_message = "Must be a valid ip address with mask"
  }
}
variable "iac_ad_vulnbox_count" {
  description = "Number of vulnboxes to create"
  type        = number
  default     = 1
  validation {
    condition     = var.iac_ad_vulnbox_count > 0 && var.iac_ad_vulnbox_count <= 250
    error_message = "The number of vulnboxes must be greater than 0 and no more than 250"
  }
}
variable "iac_ad_wireguard_port" {
  description = "Port to use for the wireguard VPN"
  type        = number
  default     = 51820
  validation {
    condition     = var.iac_ad_wireguard_port >= 80 && var.iac_ad_wireguard_port <= 65535
    error_message = "The wireguard port must be between 80 and 65535"
  }
}
variable "iac_ad_server_ports" {
  description = "Ports to open on the game system"
  type        = set(number)
  default     = [80, 443]

  validation {
    condition     = length(var.iac_ad_server_ports) > 0
    error_message = "At least one port must be specified"
  }

  validation {
    condition     = alltrue([for port in var.iac_ad_server_ports : port >= 20 && port <= 65535])
    error_message = "Ports must be between 20 and 65535"
  }
}
