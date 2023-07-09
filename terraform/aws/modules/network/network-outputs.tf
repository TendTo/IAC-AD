output "network_id" {
  value = aws_vpc.vpc.id
}
output "router_subnet_id" {
  value = aws_subnet.router_subnet.id
}
output "vulnbox_subnet_id" {
  value = aws_subnet.vulnbox_subnet.id
}
output "server_subnet_id" {
  value = aws_subnet.server_subnet.id
}
output "vulnbox_secgroup_id" {
  value = aws_security_group.vulnbox_secgroup.id
}
output "router_secgroup_id" {
  value = aws_security_group.router_secgroup.id
}
output "server_secgroup_id" {
  value = aws_security_group.server_secgroup.id
}
