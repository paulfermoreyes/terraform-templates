variable "APP_NAME" {}

# Instance
variable "WEB_SERVER_CONFIG" {
  type = object({
    LINUX_AMI            = string
    SSH_PORT             = number
    ADMIN_SECURITY_GROUP = string
    ALLOWED_IP_RANGES    = list(string)
    EC2_KEYPAIR_NAME     = string
    PUBLIC_SUBNET_ID     = string
  })
}
