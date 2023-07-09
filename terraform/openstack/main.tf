# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.51.1"
    }
  }
}

# Configure the OpenStack Provider and choose the cloud to use
provider "openstack" {
  cloud = var.iac_ad_cloud # Name of the cloud to use, usually set in ~/.config/openstack/clouds.yaml.
  # Alternatively, you can specify the credentials below.

  # user_name   = "admin"
  # tenant_name = "admin"
  # password    = "pwd"
  # auth_url    = "http://myauthurl:5000/v2.0"
  # region      = "RegionOne"
}

# ===============================
# Network
# ===============================
resource "openstack_networking_network_v2" "iac_ad_network" {
  name           = "iac_ad_network"
  admin_state_up = true
}

# ===============================
# Modules
# ===============================
module "router" {
  source     = "./modules/router"
  depends_on = [module.vulnbox]

  router_flavor_name    = var.iac_ad_router_flavor_name
  router_image_id       = var.iac_ad_router_image_id
  router_wireguard_port = var.iac_ad_wireguard_port
  network_id            = openstack_networking_network_v2.iac_ad_network.id
  router_cidr           = var.iac_ad_router_subnet_cidr
  vulnbox_cidr          = var.iac_ad_vulnbox_subnet_cidr
  external_network_id   = var.iac_ad_external_network_id
  vulnbox_count         = var.vulnbox_count
}

module "vulnbox" {
  source = "./modules/vulnbox"
  count  = var.vulnbox_count

  vulnbox_flavor_name   = var.iac_ad_vulnbox_flavor_name
  vulnbox_image_id      = var.iac_ad_vulnbox_image_id
  vulnbox_service_ports = [8080, 3000]
  team_id               = count.index + 1
  network_id            = openstack_networking_network_v2.iac_ad_network.id
  subnet_cidr           = var.iac_ad_vulnbox_subnet_cidr
}

# ===============================
# Outputs
# ===============================
output "private_key_vulnbox" {
  value = module.vulnbox[*].private_key
}
output "private_key_router" {
  value = module.router.private_key
}
output "public_ip" {
  value = module.router.public_ip
}
