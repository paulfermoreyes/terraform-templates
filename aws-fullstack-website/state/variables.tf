# Variable definitions
variable "app_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "default_tags" {
  type = map(any)
}

variable "region" {
  type        = string
  description = "AWS Deployment Region"
}
