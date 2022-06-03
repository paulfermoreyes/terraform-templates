terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.1.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  default_tags {
    tags = var.default_tags
  }
}

# Data source for existing VPC
data "aws_vpc" "default" {
  id = var.vpc_id
}

# Subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "public"
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "private"
  }
}

### Backend Resources
module "backend" {
  source = "./modules/backend"

  # Global
  app_name           = var.app_name
  env                = var.env
  vpc_cidr           = data.aws_vpc.default.cidr_block
  vpc_id             = data.aws_vpc.default.id
  default_ami        = var.linux_ami
  availability_zones = var.availability_zones
  private_subnets    = data.aws_subnets.private.ids
  public_subnets     = data.aws_subnets.public.ids

  # Database
  db_instance_id       = var.db_instance_id
  db_name              = var.db_name
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_username          = var.db_username
  db_password          = var.db_password

  # Redis
  cache_node_type = var.cache_node_type

  # Outputs:
  # - Backend instance ID
  # - Backend port?
}

### Frontend Resources
module "frontend" {
  source = "./modules/frontend"

  # Global
  # app_url      = contains(["staging", "stg"], var.env) ? "${var.app_name}-staging.${var.app_fqdn}" : "${var.app_name}.${var.app_fqdn}"
  app_url       = var.app_fqdn
  env           = var.env
  versioning    = "Enabled"
  bucket_policy = var.frontend_bucket_policy

  # Outputs:
  # - URL
  # - S3 Bucket ID
}

## Cloudfront and DNS
module "cdn" {
  source              = "./modules/cdn"
  env                 = var.env
  app_name            = var.app_name
  app_fqdn            = var.app_fqdn
  cloudfront_config   = var.cloudfront_config
  s3_bucket           = module.frontend.s3_bucket
  backend_lb_fqdn     = module.backend.load_balancer_dns_name
  acm_certificate_arn = var.acm_certificate_arn
  route_zone_id       = var.app_hosted_zone_id
}
