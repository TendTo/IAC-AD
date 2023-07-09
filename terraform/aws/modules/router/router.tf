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
# Key pair
# ===============================
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "router_key_pair"
  public_key = tls_private_key.private_key.public_key_openssh
}

# ===========================================
# Router instance
# ===========================================
resource "aws_instance" "router" {
  ami                    = var.router_image_id
  instance_type          = var.router_instance_type
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = var.router_subnet_id
  vpc_security_group_ids = [var.router_secgroup_id]

  tags = {
    Name = "router_instance"
  }
}
