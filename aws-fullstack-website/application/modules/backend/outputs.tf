output "load_balancer_sec_group_id" {
  value = aws_security_group.load_balancer_sec_group.id
}

output "load_balancer_dns_name" {
  value = aws_lb.load_balancer.dns_name
}