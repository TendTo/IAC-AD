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
  key_name   = "server_key_pair"
  public_key = tls_private_key.private_key.public_key_openssh
}

# ===========================================
# Server instance
# ===========================================
resource "aws_instance" "server" {
  ami                    = var.server_image_id
  instance_type          = var.server_instance_type
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = var.server_subnet_id
  vpc_security_group_ids = [var.server_secgroup_id]

  tags = {
    Name = "server_instance"
  }
}
