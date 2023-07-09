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
  key_name   = "vulnbox_key_pair_${var.team_id}"
  public_key = tls_private_key.private_key.public_key_openssh
}

# ===========================================
# Vulnbox instance
# ===========================================
resource "aws_instance" "vulnbox" {
  ami                    = var.vulnbox_image_id
  instance_type          = var.vulnbox_instance_type
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = var.vulnbox_subnet_id
  vpc_security_group_ids = [var.vulnbox_secgroup_id]

  tags = {
    Name = "vulnbox_instance_${var.team_id}"
  }
}

