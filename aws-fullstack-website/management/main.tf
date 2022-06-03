terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.1.0"
    }
  }

  backend "s3" {
    encrypt = true
    key     = "terraform.tfstate"
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  default_tags {
    tags = var.default_tags
  }
}

### VPC Network
module "network" {
  source = "./modules/networking"

  app_name           = var.app_name
  region             = var.region
  cidr_block         = var.vpc_cidr
  ec2_keypair_pub    = var.ec2_keypair_pub
  public_subnets     = var.public_subnets_cidr
  private_subnets    = var.private_subnets_cidr
  availability_zones = var.availability_zones
}

### Bastion instance
module "bastion" {
  source                     = "./modules/bastion"
  app_name                   = var.app_name
  allowed_admin_ip_addresses = var.allowed_admin_ip_addresses
  bastion_port               = var.bastion_port
  default_ami                = var.linux_ami
  private_subnets            = module.network.private_subnet_list
  public_subnets             = module.network.public_subnet_list
  vpc_id                     = module.network.vpc_id
}

### Workspace instance
module "workspace" {
  source                    = "./modules/workspace"
  app_name                  = var.app_name
  default_ami               = var.linux_ami
  default_security_group_id = module.network.default_security_group.id
  private_subnets           = module.network.private_subnet_list
  public_subnets            = module.network.public_subnet_list
  vpc_id                    = module.network.vpc_id
}
