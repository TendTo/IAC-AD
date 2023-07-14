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
# Public IP
# ===============================
resource "openstack_networking_floatingip_v2" "public_ip" {
  pool        = var.floating_ip_pool
  description = "Public IP used to access the router"
}

# ===============================
# Key pair
# ===============================
resource "openstack_compute_keypair_v2" "keypair" {
  name = "router_key_pair"
}

# ===============================
# Add public ip to router
# ===============================
resource "openstack_compute_floatingip_associate_v2" "public_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
  instance_id = openstack_compute_instance_v2.router.id
  fixed_ip    = openstack_compute_instance_v2.router.network.0.fixed_ip_v4
}

# ===============================
# Router port to the subnet
# ===============================
resource "openstack_networking_port_v2" "router_port" {
  name           = "router_port"
  admin_state_up = true
  network_id     = var.network_id

  security_group_ids = [
    var.router_secgroup_id
  ]

  fixed_ip {
    subnet_id = var.router_subnet_id
  }
}

# ===========================================
# Router instance instance
# ===========================================
resource "openstack_compute_instance_v2" "router" {
  name            = "router_instance"
  image_id        = var.router_image_id
  flavor_name     = var.router_flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name

  metadata = {
    application = "router"
  }

  network {
    port = openstack_networking_port_v2.router_port.id
  }
}
