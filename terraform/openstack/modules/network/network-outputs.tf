output "network_id" {
  value = openstack_networking_network_v2.network.id
}
output "router_subnet_id" {
  value = openstack_networking_subnet_v2.router_subnet.id
}
output "vulnbox_subnet_id" {
  value = openstack_networking_subnet_v2.vulnbox_subnet.id
}
output "server_subnet_id" {
  value = openstack_networking_subnet_v2.server_subnet.id
}
output "vulnbox_secgroup_id" {
  value = openstack_networking_secgroup_v2.vulnbox_secgroup.id
}
output "router_secgroup_id" {
  value = openstack_networking_secgroup_v2.router_secgroup.id
}
output "server_secgroup_id" {
  value = openstack_networking_secgroup_v2.server_secgroup.id
}
