output "private_key" {
  value     = openstack_compute_keypair_v2.keypair.private_key
  sensitive = true
}
output "private_ip" {
  value = openstack_compute_instance_v2.server.network.0.fixed_ip_v4
}
