# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.iac_ad_az_subscription_id
  tenant_id       = var.iac_ad_az_tenant_id
}

# ===============================
# Resource group
# ===============================
resource "azurerm_resource_group" "resource_group" {
  name     = var.iac_ad_az_resource_group_name
  location = var.iac_ad_az_location
}

# ===============================
# Network
# ===============================
module "network" {
  source = "./modules/network"

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  network_cidr   = var.iac_ad_network_cidr
  server_ports   = var.iac_ad_server_ports
  wireguard_port = var.iac_ad_wireguard_port

  router_subnet_cidr  = var.iac_ad_router_subnet_cidr
  vulnbox_subnet_cidr = var.iac_ad_vulnbox_subnet_cidr
  server_subnet_cidr  = var.iac_ad_server_subnet_cidr
}

# # ===============================
# # Modules
# # ===============================
module "router" {
  source     = "./modules/router"
  depends_on = [module.network]

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  router_subnet_id       = module.network.router_subnet_id
  router_secgroup_id     = module.network.router_secgroup_id
  router_app_secgroup_id = module.network.router_app_secgroup_id

  router_size  = var.iac_ad_router_size
  router_image = var.iac_ad_router_image
}

module "server" {
  source     = "./modules/server"
  depends_on = [module.network]

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  server_subnet_id   = module.network.server_subnet_id
  server_secgroup_id = module.network.server_secgroup_id

  server_image = var.iac_ad_server_image
  server_size  = var.iac_ad_server_size
}

module "vulnbox" {
  source     = "./modules/vulnbox"
  count      = var.iac_ad_vulnbox_count
  depends_on = [module.network]

  team_id = count.index + 1

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  vulnbox_subnet_id   = module.network.vulnbox_subnet_id
  vulnbox_secgroup_id = module.network.vulnbox_secgroup_id

  vulnbox_size  = var.iac_ad_vulnbox_size
  vulnbox_image = var.iac_ad_vulnbox_image
}

# # ===============================
# # Outputs
# # ===============================
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
  value = module.router.public_ip
}
output "private_ip_server" {
  value = module.server.private_ip
}
