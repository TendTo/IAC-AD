# ===============================
# Required variables
# ===============================
variable "floating_ip_pool" {
  description = "Name of the floating IP pool to use to get a public IP address"
  type        = string
}
variable "external_network_id" {
  description = "ID of the external network to connect to, used to access the internet"
  type        = string
}
variable "router_subnet_cidr" {
  description = "CIDR of the subnet of the router. Meaning the range of IP addresses that will be available for the instances in the subnet."
  type        = string
}
variable "vulnbox_subnet_cidr" {
  description = "CIDR of the subnet of the vulnbox. Meaning the range of IP addresses that will be available for the instances in the subnet."
  type        = string
}
variable "server_subnet_cidr" {
  description = "CIDR of the subnet of the server. Meaning the range of IP addresses that will be available for the instances in the subnet."
  type        = string
}
variable "server_ports" {
  description = "List of ports the server uses and accepts connections to"
  type        = set(string)

  validation {
    condition     = length(var.server_ports) > 0
    error_message = "At least one port must be specified"
  }

  validation {
    condition     = alltrue([for port in var.server_ports : port >= 20 && port <= 65535])
    error_message = "Ports must be between 20 and 65535"
  }
}
variable "wireguard_port" {
  description = "Port to use for the wireguard VPN"
  type        = number
  default     = 51820
  validation {
    condition     = var.wireguard_port >= 80 && var.wireguard_port <= 65535
    error_message = "The wireguard port must be between 80 and 65535"
  }
}
