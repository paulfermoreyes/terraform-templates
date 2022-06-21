variable "APP_NAME" {}

variable "ADMIN_IP_ADDRESSES" {
  default = []
}

variable "ALLOWED_IP_RANGES" {
  default = [
    "0.0.0.0/0"
  ]
}

variable "VPC" {
  default = {
    ADMIN_IP_RANGES = []
    CIDR_BLOCK      = "172.16.0.0/16"
    PRIVATE_SUBNETS = [
      #   "172.16.0.0/24",
      #   "172.16.1.0/24"
    ]
    PUBLIC_SUBNETS = [
      "172.16.100.0/24"
      #   "172.16.100.0/24",
      #   "172.16.101.0/24"
    ]
    AVAILABILITY_ZONES = [
      "ap-southeast-1a"
      #   "ap-southeast-1a",
      #   "ap-southeast-1b"
    ]
  }
}

variable "REGION" {
  type    = string
  default = "ap-southeast-1"
}

variable "DEFAULT_TAGS" {
  default = {
    Purpose = "Balsam Assessment"
    Contact = "paulfermoreyes@gmail.com"
  }
}

variable "EC2_INSTANCE_AMI" {
  type    = string
  default = "ami-077adc6cbd1190080"
}

variable "SSH_PUBLIC_KEY_PATH" {
  type = string
}
