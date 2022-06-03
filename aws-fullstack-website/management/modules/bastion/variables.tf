variable "app_name" {}
variable "allowed_admin_ip_addresses" {}
variable "availability_zone" {
  default = "ap-southeast-1"
}
variable "bastion_port" {}
variable "default_ami" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "vpc_id" {}
