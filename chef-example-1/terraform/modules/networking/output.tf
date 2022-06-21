output "vpc_id" {
  value = "${aws_vpc.main.id}"
}


output "public_subnet_ids" {
  value = [for s in aws_subnet.public_subnet : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_subnet : s.id]
}

output "default_security_group" {
  value = aws_default_security_group.default
}

output "admin_security_group" {
  value = aws_security_group.admin
}
