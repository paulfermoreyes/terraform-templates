
resource "aws_instance" "server" {
  ami                         = var.WEB_SERVER_CONFIG.LINUX_AMI
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name = "${var.APP_NAME}-nginx-server"
  }

  root_block_device {
    volume_size = 30
  }

  # iam_instance_profile = aws_iam_instance_profile.default.id

  # Public SSH Key Name
  key_name = var.WEB_SERVER_CONFIG.EC2_KEYPAIR_NAME

  subnet_id = var.WEB_SERVER_CONFIG.PUBLIC_SUBNET_ID

  # Security Group
  vpc_security_group_ids = [var.WEB_SERVER_CONFIG.ADMIN_SECURITY_GROUP]

  credit_specification {
    cpu_credits = "standard"
  }
  user_data = <<EOF
#!/bin/bash

echo "Installing Chef Workstation"
# Reference: https://www.chef.io/downloads/tools/workstation?os=ubuntu
wget https://packages.chef.io/files/stable/chef-workstation/22.6.973/ubuntu/20.04/chef-workstation_22.6.973-1_amd64.deb
sudo dpkg -i chef-workstation_22.6.973-1_amd64.deb

echo "Creating Swap File"
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

echo "Installing Chef"
wget https://packages.chef.io/files/stable/chef-server/14.16.19/ubuntu/20.04/chef-server-core_14.16.19-1_amd64.deb

EOF
}
