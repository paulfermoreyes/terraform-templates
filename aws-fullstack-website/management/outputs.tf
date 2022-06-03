output "vpc" {
    value = {
        vpc_id = module.network.vpc_id
        vpc_cidr = var.vpc_cidr
    }
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "workspace_internal_ip" {
  value = module.workspace.workspace_internal_ip
}