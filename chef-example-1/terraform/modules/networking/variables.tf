variable "APP_NAME" {}
variable "WITH_KOPS" {
  type    = bool
  default = false
}

variable "REGION" {}
variable "CIDR_BLOCK" {}
variable "ADMIN_IP_ADDRESSES" {}
variable "PRIVATE_SUBNETS" {}
variable "PUBLIC_SUBNETS" {}
variable "AVAILABILITY_ZONES" {}
