# ===============================
# Required variables
# ===============================
variable "iac_ad_az_location" {
  type        = string
  description = "Name of the region to deploy the resources in. (westeurope, eastus, etc.)"
}
variable "iac_ad_az_resource_group_name" {
  type        = string
  description = "Name of the resource group to create. It will contain all the resources created by this terraform script."
}
variable "iac_ad_vulnbox_image" {
  description = "Virtual Machine source image information for the vulnbox."
  type        = map(string)
}
variable "iac_ad_vulnbox_size" {
  type        = string
  description = "Identifier of the size to use for the vulnboxes. It determins the instance's computing power. (DStandard_2s_v3, DStandard_4s_v3, BStandard_2ms, etc.)"
}
variable "iac_ad_server_image" {
  description = "Virtual Machine source image information for the server."
  type        = map(string)
}
variable "iac_ad_server_size" {
  type        = string
  description = "Identifier of the size to use for the server. It determins the instance's computing power. (DStandard_2s_v3, DStandard_4s_v3, BStandard_2ms, etc.)"
}
variable "iac_ad_router_image" {
  description = "Virtual Machine source image information for the router."
  type        = map(string)
}
variable "iac_ad_router_size" {
  type        = string
  description = "Identifier of the size to use for the router. It determins the instance's computing power. (DStandard_2s_v3, DStandard_4s_v3, BStandard_2ms, etc.)"
}
# ===============================
# Terraform optional variables
# ===============================
variable "iac_ad_az_tenant_id" {
  type        = string
  description = "Id of the tenant who will deploy the resources on Azure. If null, the parameter will be read from the az cli configuration"
  default     = null
}
variable "iac_ad_az_subscription_id" {
  type        = string
  description = "Id of the subscription used to deploy the resources on Azure. If null, the parameter will be read from the az cli configuration"
  default     = null
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
