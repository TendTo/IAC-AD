output "private_key" {
  value     = tls_private_key.private_key.private_key_openssh
  sensitive = true
}
output "public_ip" {
  value = aws_instance.router.public_ip
}
output "private_ip" {
  value = aws_instance.router.private_ip
}
