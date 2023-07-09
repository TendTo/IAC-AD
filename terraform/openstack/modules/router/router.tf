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
# Key pair
# ===============================
resource "openstack_compute_keypair_v2" "iac_ad_keypair" {
  name = "iac_ad_keypair_router"

}

# ===============================
# Public IP
# ===============================
resource "openstack_networking_floatingip_v2" "iac_ad_public_ip" {
  pool        = "floating-ip"
  description = "Public IP used to access the VPN server"
}

resource "openstack_compute_floatingip_associate_v2" "iac_ad_public_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.iac_ad_public_ip.address
  instance_id = openstack_compute_instance_v2.iac_ad_instance.id
  fixed_ip    = openstack_compute_instance_v2.iac_ad_instance.network.0.fixed_ip_v4
}

# ===============================
# External router
# ===============================
resource "openstack_networking_router_v2" "iac_ad_external_router" {
  external_network_id = var.external_network_id
}

resource "openstack_networking_router_interface_v2" "iac_ad_external_router_interface" {
  router_id = openstack_networking_router_v2.iac_ad_external_router.id
  subnet_id = openstack_networking_subnet_v2.iac_ad_subnet.id
}

# ===========================================
# Subnet hosting the router
# ===========================================
resource "openstack_networking_subnet_v2" "iac_ad_subnet" {
  name       = "iac_ad_subnet_router"
  network_id = var.network_id
  # Format the IP address. The format string is in the form X.X.X.%d/mask
  # The result is in the form X.X.X.0/mask
  cidr            = format(var.router_cidr, "0")
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]
}

# ===========================================
# Security group for the router
# ===========================================
resource "openstack_networking_secgroup_v2" "iac_ad_secgroup" {
  name                 = "iac_ad_vulnbox_secgroup_router"
  description          = "Security group for the router"
  delete_default_rules = true

  # rule {
  #   from_port   = 22
  #   to_port     = 22
  #   ip_protocol = "tcp"
  #   cidr        = "0.0.0.0/0"
  # }

  # rule {
  #   from_port   = var.router_wireguard_port
  #   to_port     = var.router_wireguard_port
  #   ip_protocol = "udp"
  #   cidr        = "0.0.0.0/0"
  # }

  # # TODO: remove
  # rule {
  #   from_port   = -1
  #   to_port     = -1
  #   ip_protocol = "icmp"
  #   cidr        = "0.0.0.0/0"
  # }
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.iac_ad_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_egress_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.iac_ad_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ingress_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.iac_ad_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ingress_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.iac_ad_secgroup.id
}


# ===========================================
# Router instance instance
# ===========================================
resource "openstack_compute_instance_v2" "iac_ad_instance" {
  name            = "iac_ad_router_instance"
  image_id        = var.router_image_id
  flavor_name     = var.router_flavor_name
  key_pair        = openstack_compute_keypair_v2.iac_ad_keypair.name
  security_groups = [openstack_networking_secgroup_v2.iac_ad_secgroup.name]

  metadata = {
    application = "router"
  }

  # TODO: remove
  user_data = file("${path.module}/router_user_data.txt")

  network {
    uuid = var.network_id
    # Format the IP address. The format string is in the form X.X.X.%d/mask
    # The result is in the form X.X.X.254
    fixed_ip_v4 = split("/", format(var.router_cidr, "254"))[0]
  }

  dynamic "network" {
    for_each = range(1, var.vulnbox_count + 1)
    content {
      uuid = var.network_id
      # Format the IP address. The format string is in the form X.X.X.%d/mask
      # The result is in the form X.X.X.254
      fixed_ip_v4 = split("/", format(var.vulnbox_cidr, network.value, "254"))[0]
    }
  }
}
