output "private_key" {
  value     = tls_private_key.private_key.private_key_openssh
  sensitive = true
}
output "private_ip" {
  value = aws_instance.vulnbox.private_ip
}
