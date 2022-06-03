#####################################
##### Bastion Network Interface #####
#####################################
resource "aws_network_interface" "bastion" {
  subnet_id = var.public_subnets[0]
  tags = {
    Name = "${var.app_name}-bastion-network-if"
  }
}

############################
##### Bastion Instance #####
############################
resource "aws_instance" "bastion" {
  ami                  = var.default_ami
  instance_type        = "t2.micro"
  key_name             = "${var.app_name}-keypair"
  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  tags = {
    Name = "${var.app_name}-bastion"
  }
}

###################################
##### Bastion Public IP (EIP) #####
###################################
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  vpc      = true
  tags = {
    Name = "${var.app_name}-bastion-eip"
  }
}

##################################
##### Bastion Security Group #####
##################################
resource "aws_security_group" "allow_admins" {
  name        = "${var.app_name}-sg-allow-admins"
  description = "Allow bastion access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Public IP"
    from_port   = var.bastion_port
    to_port     = var.bastion_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_admin_ip_addresses
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg-allow-admins"
  }
}

##################################
##### Bastion Security Group Attachment #####
##################################
resource "aws_network_interface_sg_attachment" "bastion_sg_attachment" {
  security_group_id    = aws_security_group.allow_admins.id
  network_interface_id = aws_instance.bastion.primary_network_interface_id
}
