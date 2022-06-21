terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.19.0"
    }
  }
}

provider "aws" {
  region = var.REGION
  default_tags {
    tags = var.DEFAULT_TAGS
  }
}

resource "aws_key_pair" "admin_keypair" {
  key_name   = "${var.APP_NAME}-admin-keypair"
  public_key = file(var.SSH_PUBLIC_KEY_PATH)
}


### VPC Network
module "network" {
  source = "./modules/networking"

  APP_NAME           = var.APP_NAME
  REGION             = var.REGION
  CIDR_BLOCK         = var.VPC.CIDR_BLOCK
  ADMIN_IP_ADDRESSES = var.VPC.ADMIN_IP_RANGES
  PUBLIC_SUBNETS     = var.VPC.PUBLIC_SUBNETS
  PRIVATE_SUBNETS    = var.VPC.PRIVATE_SUBNETS
  AVAILABILITY_ZONES = var.VPC.AVAILABILITY_ZONES
}

module "web" {
  source = "./modules/web"

  APP_NAME = var.APP_NAME
  WEB_SERVER_CONFIG = {
    LINUX_AMI            = var.EC2_INSTANCE_AMI
    ADMIN_SECURITY_GROUP = module.network.admin_security_group.id
    SSH_PORT             = 22
    ALLOWED_IP_RANGES    = var.ALLOWED_IP_RANGES
    EC2_KEYPAIR_NAME     = aws_key_pair.admin_keypair.key_name
    PUBLIC_SUBNET_ID     = module.network.public_subnet_ids[0]
  }
}
