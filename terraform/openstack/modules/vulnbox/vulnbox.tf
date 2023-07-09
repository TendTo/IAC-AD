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
  name = "iac_ad_keypair_${var.team_id}"
}

# ===========================================
# Subnet hosting the vulnbox
# ===========================================
resource "openstack_networking_subnet_v2" "iac_ad_subnet" {
  name       = "iac_ad_subnet_${var.team_id}"
  network_id = var.network_id
  # Format the IP address. The format string is in the form X.X.%d.%d/mask
  # The result is in the form X.X.(var.team_id).0/mask
  cidr            = format(var.subnet_cidr, var.team_id, "0")
  ip_version      = 4
  dns_nameservers = ["8.8.8.8"]
  no_gateway      = true

  # The gateway IP address is in the form X.X.(var.team_id).254. It corresponds to the ip of the router
  # gateway_ip = split("/", format(var.subnet_cidr, var.team_id, "254"))[0]
}

# ===========================================
# Security group for the vulnerable services
# ===========================================
# resource "openstack_compute_secgroup_v2" "iac_ad_secgroup" {
#   name        = "iac_ad_vulnbox_secgroup_${var.team_id}"
#   description = "Security group for the vulnerable services"

#   rule {
#     from_port   = 22
#     to_port     = 22
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }

#   dynamic "rule" {
#     for_each = var.vulnbox_service_ports
#     content {
#       from_port   = rule.value
#       to_port     = rule.value
#       ip_protocol = "tcp"
#       cidr        = "0.0.0.0/0"
#     }
#   }

#   # TODO: remove
#   rule {
#     from_port   = -1
#     to_port     = -1
#     ip_protocol = "icmp"
#     cidr        = "0.0.0.0/0"
#   }
# }

# ===========================================
# Security group for the router
# ===========================================
resource "openstack_networking_secgroup_v2" "iac_ad_secgroup" {
  name                 = "iac_ad_vulnbox_secgroup_${var.team_id}"
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
# Vulnbox instance
# ===========================================
resource "openstack_compute_instance_v2" "iac_ad_instance" {
  name            = "iac_ad_vulnbox_instance_${var.team_id}"
  image_id        = var.vulnbox_image_id
  flavor_name     = var.vulnbox_flavor_name
  key_pair        = openstack_compute_keypair_v2.iac_ad_keypair.name
  security_groups = [openstack_networking_secgroup_v2.iac_ad_secgroup.name]

  metadata = {
    application = "vunlbox_${var.team_id}"
  }

  user_data = format(file("${path.module}/vulnbox_user_data.txt"), split("/", format(var.subnet_cidr, var.team_id, "254"))[0])

  network {
    uuid = var.network_id
    # Format the IP address. The format string is in the form X.X.%d.%d/mask
    # The result is in the form X.X.(var.team_id).2
    fixed_ip_v4 = split("/", format(var.subnet_cidr, var.team_id, "4"))[0]
  }
}
