output "private_key" {
  value     = tls_private_key.private_key.private_key_openssh
  sensitive = true
}
output "private_ip" {
  value = azurerm_network_interface.vulnbox_network_interface.private_ip_address
}
