# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = var.iac_ad_aws_region
  profile                  = var.iac_ad_aws_profile
  shared_credentials_files = [var.iac_ad_aws_credentials_file]
}

# ===============================
# Network
# ===============================
module "network" {
  source = "./modules/network"

  network_cidr   = var.iac_ad_network_cidr
  server_ports   = var.iac_ad_server_ports
  wireguard_port = var.iac_ad_wireguard_port

  router_subnet_cidr  = var.iac_ad_router_subnet_cidr
  vulnbox_subnet_cidr = var.iac_ad_vulnbox_subnet_cidr
  server_subnet_cidr  = var.iac_ad_server_subnet_cidr
}

# ===============================
# Modules
# ===============================
module "router" {
  source     = "./modules/router"
  depends_on = [module.network]

  router_subnet_id   = module.network.router_subnet_id
  router_secgroup_id = module.network.router_secgroup_id

  router_instance_type = var.iac_ad_router_instance_type
  router_image_id      = var.iac_ad_router_image_id
}

module "server" {
  source     = "./modules/server"
  depends_on = [module.network]

  server_subnet_id   = module.network.server_subnet_id
  server_secgroup_id = module.network.server_secgroup_id

  server_image_id      = var.iac_ad_server_image_id
  server_instance_type = var.iac_ad_server_instance_type
}

module "vulnbox" {
  source     = "./modules/vulnbox"
  count      = var.iac_ad_vulnbox_count
  depends_on = [module.network]

  team_id = count.index + 1

  vulnbox_subnet_id   = module.network.vulnbox_subnet_id
  vulnbox_secgroup_id = module.network.vulnbox_secgroup_id

  vulnbox_instance_type = var.iac_ad_vulnbox_instance_type
  vulnbox_image_id      = var.iac_ad_vulnbox_image_id
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
  value = module.router.public_ip
}
output "private_ip_router" {
  value = module.router.private_ip
}
output "private_ip_server" {
  value = module.server.private_ip
}
