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
# Network
# ===============================
resource "azurerm_virtual_network" "network" {
  name                = "iac_ad_network"
  address_space       = [var.network_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# ===============================
# Nat gateway
# ===============================
resource "azurerm_public_ip" "nat_gateway_ip" {
  name                = "iac_ad_nat_gateway_ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "iac_ad_nat_gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "vulnbox_subnet_nat_gateway_association" {
  subnet_id      = azurerm_subnet.vulnbox_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "server_subnet_nat_gateway_association" {
  subnet_id      = azurerm_subnet.server_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

# ===============================
# Security groups
# ===============================
resource "azurerm_application_security_group" "router_app_secgroup" {
  name                = "iac_ad_router_app_secgroup"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "router_secgroup" {
  name                = "iac_ad_router_secgroup"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "wireguard"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = var.wireguard_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "default_deny"
    priority                   = 4090
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "vulnbox_secgroup" {
  name                = "iac_ad_vulnbox_secgroup"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                                  = "all"
    priority                              = 1001
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "*"
    destination_address_prefix            = "*"
    source_application_security_group_ids = [azurerm_application_security_group.router_app_secgroup.id]
  }

  security_rule {
    name                       = "default_deny"
    priority                   = 4090
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "server_secgroup" {
  name                = "iac_ad_server_secgroup"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = { for idx, port in var.server_ports : idx => port }
    content {
      name                                  = "port_${security_rule.value}"
      priority                              = sum([100, security_rule.key])
      direction                             = "Inbound"
      access                                = "Allow"
      protocol                              = "Tcp"
      source_port_range                     = "*"
      destination_port_range                = security_rule.value
      destination_address_prefix            = "*"
      source_application_security_group_ids = [azurerm_application_security_group.router_app_secgroup.id]
    }
  }

  security_rule {
    name                       = "default_deny"
    priority                   = 4090
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "router_subnet_secgroup_association" {
  subnet_id                 = azurerm_subnet.router_subnet.id
  network_security_group_id = azurerm_network_security_group.router_secgroup.id
}

resource "azurerm_subnet_network_security_group_association" "vulnbox_subnet_secgroup_association" {
  subnet_id                 = azurerm_subnet.vulnbox_subnet.id
  network_security_group_id = azurerm_network_security_group.vulnbox_secgroup.id
}

resource "azurerm_subnet_network_security_group_association" "server_subnet_secgroup_association" {
  subnet_id                 = azurerm_subnet.server_subnet.id
  network_security_group_id = azurerm_network_security_group.server_secgroup.id
}

# ===============================
# Subnets
# ===============================
resource "azurerm_subnet" "router_subnet" {
  name                 = "iac_ad_router_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.router_subnet_cidr]
}

resource "azurerm_subnet" "vulnbox_subnet" {
  name                 = "iac_ad_vulnbox_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.vulnbox_subnet_cidr]
}

resource "azurerm_subnet" "server_subnet" {
  name                 = "iac_ad_server_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.server_subnet_cidr]
}
