output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "public_subnet_list" {
  value = [for s in aws_subnet.public_subnet : s.id]
}

output "private_subnet_list" {
  value = [for s in aws_subnet.private_subnet : s.id]
}

output "default_security_group" {
  value = aws_security_group.default
}