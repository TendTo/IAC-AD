output "network_id" {
  value = azurerm_virtual_network.network.id
}
output "router_subnet_id" {
  value = azurerm_subnet.router_subnet.id
}
output "vulnbox_subnet_id" {
  value = azurerm_subnet.vulnbox_subnet.id
}
output "server_subnet_id" {
  value = azurerm_subnet.server_subnet.id
}
output "vulnbox_secgroup_id" {
  value = azurerm_network_security_group.vulnbox_secgroup.id
}
output "router_secgroup_id" {
  value = azurerm_network_security_group.router_secgroup.id
}
output "router_app_secgroup_id" {
  value = azurerm_application_security_group.router_app_secgroup.id
}
output "server_secgroup_id" {
  value = azurerm_network_security_group.server_secgroup.id
}
