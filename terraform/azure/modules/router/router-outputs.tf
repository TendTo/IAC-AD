output "private_key" {
  value     = tls_private_key.private_key.private_key_openssh
  sensitive = true
}
output "public_ip" {
  value = data.azurerm_public_ip.pubLic_ip.ip_address
}
