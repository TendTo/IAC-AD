# ===============================
# Provider
# ===============================
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }
}

# ===============================
# Key pair
# ===============================
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ===============================
# Public ip
# ===============================
resource "azurerm_public_ip" "public_ip" {
  name                = "iac_ad_router_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "pubLic_ip" {
  depends_on          = [azurerm_linux_virtual_machine.router]
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = var.resource_group_name
}

# ===============================
# Network interface
# ===============================
resource "azurerm_network_interface" "router_network_interface" {
  name                = "iac_ad_router_network_interface"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "router_ip_configuration"
    subnet_id                     = var.router_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_application_security_group_association" "example" {
  network_interface_id          = azurerm_network_interface.router_network_interface.id
  application_security_group_id = var.router_app_secgroup_id
}

# ===========================================
# Router instance
# ===========================================
resource "azurerm_linux_virtual_machine" "router" {
  name                = "router"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.router_size
  admin_username      = "ubuntu"

  source_image_reference {
    offer     = var.router_image.offer
    publisher = var.router_image.publisher
    sku       = var.router_image.sku
    version   = var.router_image.version
  }

  network_interface_ids = [
    azurerm_network_interface.router_network_interface.id
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.private_key.public_key_openssh
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
