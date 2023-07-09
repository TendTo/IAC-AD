# ===============================
# Provider
# ===============================
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5.0"
    }
  }
}

# ===============================
# Network
# ===============================
resource "aws_vpc" "vpc" {
  cidr_block           = var.network_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "iac_ad_vpc"
  }
}

# ===============================
# Internet gateway
# ===============================
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "router_internet_gateway"
  }
}

# ===============================
# Nat gateway
# ===============================
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.router_subnet.id

  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "router_nat_gateway"
  }
}

# ===============================
# Route tables
# ===============================
resource "aws_route_table" "router_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "router_route_table"
  }
}

resource "aws_route_table" "vulnbox_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "vulnbox_route_table"
  }
}

resource "aws_route_table" "server_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "server_route_table"
  }
}

resource "aws_route_table_association" "router_route_table_association" {
  subnet_id      = aws_subnet.router_subnet.id
  route_table_id = aws_route_table.router_route_table.id
}

resource "aws_route_table_association" "vulnbox_route_table_association" {
  subnet_id      = aws_subnet.vulnbox_subnet.id
  route_table_id = aws_route_table.vulnbox_route_table.id
}

resource "aws_route_table_association" "server_route_table_association" {
  subnet_id      = aws_subnet.server_subnet.id
  route_table_id = aws_route_table.server_route_table.id
}

# ===============================
# Security groups
# ===============================
resource "aws_security_group" "router_secgroup" {
  name        = "router_secgroup" # Use global project identifier
  description = "Security group for the router"
  vpc_id      = aws_vpc.vpc.id

  /* Allow only ssh traffic from internet */
  ingress {
    from_port        = "22"
    to_port          = "22"
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = var.wireguard_port
    to_port          = var.wireguard_port
    protocol         = "UDP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "router_secgroup"
  }
}

resource "aws_security_group" "vulnbox_secgroup" {
  name        = "vulnbox_secgroup" # Use global project identifier
  description = "Security group for the vulnerable services of the vulnboxes"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    security_groups = [aws_security_group.router_secgroup.id]
  }

  tags = {
    Name = "vulnbox_secgroup"
  }
}

resource "aws_security_group" "server_secgroup" {
  name        = "server_secgroup" # Use global project identifier
  description = "Security group for the server"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "ingress" {
    for_each = var.server_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "TCP"
      security_groups = [aws_security_group.router_secgroup.id]
    }
  }

  tags = {
    Name = "server_secgroup"
  }
}

# ===============================
# Subnets
# ===============================
resource "aws_subnet" "router_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.router_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "router_subnet"
  }
}

resource "aws_subnet" "server_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.server_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "server_subnet"
  }
}

resource "aws_subnet" "vulnbox_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vulnbox_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "vulbox_subnet"
  }
}
