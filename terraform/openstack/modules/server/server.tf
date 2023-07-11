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
resource "openstack_compute_keypair_v2" "keypair" {
  name = "server_key_pair"
}

# ===============================
# Server port to the subnet
# ===============================
resource "openstack_networking_port_v2" "server_port" {
  name           = "server_port"
  admin_state_up = true
  network_id     = var.network_id

  security_group_ids = [
    var.server_secgroup_id
  ]

  fixed_ip {
    subnet_id = var.server_subnet_id
  }
}

# ===========================================
# Server instance
# ===========================================
resource "openstack_compute_instance_v2" "server" {
  name        = "server_instance"
  image_id    = var.server_image_id
  flavor_name = var.server_flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  metadata = {
    application = "server"
  }

  network {
    port = openstack_networking_port_v2.server_port.id
  }
}
