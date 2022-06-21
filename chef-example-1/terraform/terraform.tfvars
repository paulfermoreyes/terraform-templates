APP_NAME = "bb"
ADMIN_IP_ADDRESSES = [
  "152.32.100.84/32"
]

SSH_PUBLIC_KEY_PATH = "/Users/paulfermoreyes/.ssh/bb_aws.pub"

VPC = {
  ADMIN_IP_RANGES = "152.32.100.84/32"
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
