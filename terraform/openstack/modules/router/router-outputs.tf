output "private_key" {
  value = openstack_compute_keypair_v2.iac_ad_keypair.private_key
}
output "public_ip" {
  value = openstack_networking_floatingip_v2.iac_ad_public_ip.address
}
