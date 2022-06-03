resource "aws_network_interface" "workspace" {
  subnet_id = var.public_subnets[0]

  tags = {
    Name = "${var.app_name}-workspace-network-if"
  }
}

resource "aws_instance" "workspace" {
  ami                  = var.default_ami
  instance_type        = "t2.micro"
  key_name             = "${var.app_name}-keypair"
  iam_instance_profile = "WorkspaceRole"
  network_interface {
    network_interface_id = aws_network_interface.workspace.id
    device_index         = 0
  }
  tags = {
    Name = "${var.app_name}-workspace"
  }
}

# # Requires authorization to iam:TagInstanceProfile 
# resource "aws_iam_instance_profile" "workspace" {
#   name  = "${ var.app_name }-workspace-profile"
#   role  = "${ var.app_name }-workspace-role"
# }

resource "aws_network_interface_sg_attachment" "workspace_sg_attachment" {
  security_group_id    = var.default_security_group_id
  network_interface_id = aws_instance.workspace.primary_network_interface_id
}

###### ! MANUALLY CREATED FOR NOW SINCE TAGGING IS NOT ALLOWED #########
# resource "aws_iam_role" "workspace_role" {
#   name = "${ var.app_name }-workspace-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
#     "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/IAMFullAccess",
#     "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
#     "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
#     "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
#   ]
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "ecr:*"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         "Resource": [
#             "${ var.ecr_registry.arn }"
#         ]
#       }
#     ]
#   })
# }
