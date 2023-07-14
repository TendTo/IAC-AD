output "private_key" {
  value     = openstack_compute_keypair_v2.keypair.private_key
  sensitive = true
}
output "public_ip" {
  value = openstack_networking_floatingip_v2.public_ip.address
}
