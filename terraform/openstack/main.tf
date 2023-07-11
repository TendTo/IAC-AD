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

module "network" {
  source = "./modules/network"

  floating_ip_pool    = var.iac_ad_floating_ip_pool
  router_subnet_cidr  = var.iac_ad_router_subnet_cidr
  vulnbox_subnet_cidr = var.iac_ad_vulnbox_subnet_cidr
  server_subnet_cidr  = var.iac_ad_server_subnet_cidr
  external_network_id = var.iac_ad_external_network_id
  server_ports        = var.iac_ad_server_ports
  wireguard_port      = var.iac_ad_wireguard_port
}

# ===============================
# Modules
# ===============================
module "router" {
  source     = "./modules/router"
  depends_on = [module.network]

  router_flavor_name = var.iac_ad_router_flavor_name
  router_image_id    = var.iac_ad_router_image_id

  public_ip          = module.network.public_ip
  network_id         = module.network.network_id
  router_secgroup_id = module.network.router_secgroup_id
  router_subnet_id   = module.network.router_subnet_id
}

module "vulnbox" {
  source = "./modules/vulnbox"
  count  = var.iac_ad_vulnbox_count

  team_id = count.index + 1

  vulnbox_flavor_name = var.iac_ad_vulnbox_flavor_name
  vulnbox_image_id    = var.iac_ad_vulnbox_image_id

  network_id          = module.network.network_id
  vulnbox_secgroup_id = module.network.vulnbox_secgroup_id
  vulnbox_subnet_id   = module.network.vulnbox_subnet_id
}

module "server" {
  source = "./modules/server"

  server_flavor_name = var.iac_ad_server_flavor_name
  server_image_id    = var.iac_ad_server_image_id

  network_id         = module.network.network_id
  server_secgroup_id = module.network.server_secgroup_id
  server_subnet_id   = module.network.server_subnet_id
}

# ===============================
# Outputs
# ===============================
output "private_key_vulnbox" {
  value     = module.vulnbox[*].private_key
  sensitive = true
}
output "private_key_router" {
  value     = module.router.private_key
  sensitive = true
}
output "private_key_server" {
  value     = module.server.private_key
  sensitive = true
}
output "private_ip_vulnbox" {
  value = module.vulnbox[*].private_ip
}
output "public_ip_router" {
  value = module.network.public_ip
}
output "private_ip_server" {
  value = module.server.private_ip
}
