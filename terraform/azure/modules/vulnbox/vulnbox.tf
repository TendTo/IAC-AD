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
# Network interface
# ===============================
resource "azurerm_network_interface" "vulnbox_network_interface" {
  name                = "iac_ad_vulnbox_network_interface_${var.team_id}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "vulnbox_ip_configuration_${var.team_id}"
    subnet_id                     = var.vulnbox_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ===========================================
# Server instance
# ===========================================
resource "azurerm_linux_virtual_machine" "server" {
  name                = "vulnbox-${var.team_id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vulnbox_size
  admin_username      = "ubuntu"

  source_image_reference {
    offer     = var.vulnbox_image.offer
    publisher = var.vulnbox_image.publisher
    sku       = var.vulnbox_image.sku
    version   = var.vulnbox_image.version
  }

  network_interface_ids = [
    azurerm_network_interface.vulnbox_network_interface.id
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


