output "private_key" {
  value     = openstack_compute_keypair_v2.keypair.private_key
  sensitive = true
}
