# ===============================
# Provider
# ===============================
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4.0"
    }
  }
}

# ===============================
# Key pair
# ===============================
resource "openstack_compute_keypair_v2" "keypair" {
  name = "vulnbox_key_pair_${var.team_id}"
}

# ===============================
# Vulnbox port to the subnet
# ===============================
resource "openstack_networking_port_v2" "vulnbox_port" {
  name           = "vulnbox_port_${var.team_id}"
  admin_state_up = true
  network_id     = var.network_id

  security_group_ids = [
    var.vulnbox_secgroup_id
  ]

  fixed_ip {
    subnet_id = var.vulnbox_subnet_id
  }
}

# ===========================================
# Vulnbox instance
# ===========================================
resource "openstack_compute_instance_v2" "vulnbox" {
  name        = "vulnbox_instance_${var.team_id}"
  image_id    = var.vulnbox_image_id
  flavor_name = var.vulnbox_flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  metadata = {
    application = "vunlbox_${var.team_id}"
  }

  # user_data = file("${path.module}/vulnbox_user_data.txt")

  network {
    port = openstack_networking_port_v2.vulnbox_port.id
  }
}
