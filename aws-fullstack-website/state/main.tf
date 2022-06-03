provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  default_tags {
    tags = var.default_tags
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "aws_s3_bucket" "mgmt_terraform_state" {
  bucket = "${var.app_name}-mgmt-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  } # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_s3_bucket" "app_terraform_state" {
  bucket = "${var.app_name}-app-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  } 
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# resource "aws_s3_bucket" "prd_terraform_state" {
#   bucket = "${var.app_name}-prd-state"
#   # Enable versioning so we can see the full revision history of our
#   # state files
#   versioning {
#     enabled = true
#   } # Enable server-side encryption by default
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# resource "aws_s3_bucket" "stg_terraform_state" {
#   bucket = "${var.app_name}-stg-state"
#   # Enable versioning so we can see the full revision history of our
#   # state files
#   versioning {
#     enabled = true
#   } # Enable server-side encryption by default
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }
