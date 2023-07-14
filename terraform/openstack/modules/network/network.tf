# ===============================
# Provider
# ===============================
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.51.1"
    }
  }
}

# ===============================
# Network
# ===============================
resource "openstack_networking_network_v2" "network" {
  name           = "iac_ad_network"
  admin_state_up = true
}

# ===============================
# External router
# ===============================
resource "openstack_networking_router_v2" "external_router" {
  name                = "external_router"
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "external_router_interface_router" {
  router_id = openstack_networking_router_v2.external_router.id
  subnet_id = openstack_networking_subnet_v2.router_subnet.id
}

resource "openstack_networking_router_interface_v2" "external_router_interface_vulnbox" {
  router_id = openstack_networking_router_v2.external_router.id
  subnet_id = openstack_networking_subnet_v2.vulnbox_subnet.id
}

resource "openstack_networking_router_interface_v2" "external_router_interface_server" {
  router_id = openstack_networking_router_v2.external_router.id
  subnet_id = openstack_networking_subnet_v2.server_subnet.id
}

# ===========================================
# Subnets
# ===========================================
resource "openstack_networking_subnet_v2" "router_subnet" {
  name            = "router_subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.router_subnet_cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
}

resource "openstack_networking_subnet_v2" "vulnbox_subnet" {
  name            = "vulnbox_subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.vulnbox_subnet_cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
}

resource "openstack_networking_subnet_v2" "server_subnet" {
  name            = "server_subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.server_subnet_cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
}

# ===============================
# Security groups
# ===============================
resource "openstack_networking_secgroup_v2" "router_secgroup" {
  name                 = "router_secgroup"
  description          = "Security group for the router"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "router_secgroup_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.router_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "router_secgroup_rule_egress_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.router_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "router_secgroup_rule_ingress_ssh_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.router_secgroup.id
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
}

resource "openstack_networking_secgroup_rule_v2" "router_secgroup_rule_ingress_http_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.router_secgroup.id
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
}

resource "openstack_networking_secgroup_rule_v2" "router_secgroup_rule_ingress_wireguard_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.router_secgroup.id
  port_range_min    = var.wireguard_port
  port_range_max    = var.wireguard_port
  protocol          = "udp"
}

resource "openstack_networking_secgroup_v2" "vulnbox_secgroup" {
  name                 = "vulnbox_secgroup"
  description          = "Security group for the vulnboxes"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "vulnbox_secgroup_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.vulnbox_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "vulnbox_secgroup_rule_egress_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.vulnbox_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "vulnbox_secgroup_rule_ingress_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.vulnbox_secgroup.id
  remote_group_id   = openstack_networking_secgroup_v2.router_secgroup.id
}

resource "openstack_networking_secgroup_v2" "server_secgroup" {
  name                 = "server_secgroup"
  description          = "Security group for the server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "server_secgroup_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.server_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "server_secgroup_rule_egress_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.server_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "server_secgroup_rule_ingress_v4" {
  for_each          = var.server_ports
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.server_secgroup.id
  port_range_min    = each.key
  port_range_max    = each.key
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.router_secgroup.id
}
