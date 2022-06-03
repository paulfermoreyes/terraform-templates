# Variable definitions
variable "app_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "bastion_port" {}
variable "ec2_keypair_pub" {}
variable "default_tags" {
  type = map(any)
}

variable "region" {
  type        = string
  description = "AWS Deployment Region"
}
variable "availability_zones" {
  type        = list(any)
  description = "AWS Availability Zones"
}
variable "vpc_cidr" {
  type        = string
  description = "AWS VPC CIDR"
}
variable "private_subnets_cidr" {
  type        = list(any)
  default     = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
  description = "AWS Private Subnets List"
}
variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["172.16.15.0/24", "172.16.25.0/24", "172.16.35.0/24"]
  description = "AWS Public Subnets List"
}

variable "allowed_admin_ip_addresses" {
  type        = list(any)
  default = ["110.54.148.230/32", "120.29.97.89/32", "136.158.8.20/32", "120.29.110.148/32"]
  description = "List of allowed public IP addresses to access bastion"
}

variable "linux_ami" {
  default = "ami-02a45d709a415958a"
}
