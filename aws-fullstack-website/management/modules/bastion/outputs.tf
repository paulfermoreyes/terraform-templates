output "bastion_public_ip" {
    value = aws_eip.bastion_eip.public_ip
}

output "bastion_security_group" {
  value = aws_security_group.allow_admins
}
