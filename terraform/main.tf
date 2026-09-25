module "network" {
  source              = "./modules/network"
  instance_bastion_id = module.compute.instance_bastion_id
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
  lb_arn = module.loadbalancer.lb_arn
}

module "compute" {
  source                                   = "./modules/compute"
  public_subnet_ids                        = module.network.public_subnet_ids
  private_subnet_ids                       = module.network.private_subnet_ids
  asg_auto_scaling_group_private_subnet_id = module.security.asg_auto_scaling_group_private_subnet_id
  asg_bastion_id                           = module.security.asg_bastion_id
  lb_target_group_arn                      = module.loadbalancer.lb_target_group_arn
  instance                                 = var.instance
  min_size_ec2_instance                    = var.min_size_ec2_instance
}

module "loadbalancer" {
  source               = "./modules/loadbalancer"
  asg_public_subnet_id = module.security.asg_public_subnet_id
  public_subnet_ids    = module.network.public_subnet_ids
  vpc_id               = module.network.vpc_id
}

module "database" {
  source                   = "./modules/database"
  db_pwd                   = var.db_pwd
  db_user                  = var.db_user
  private_subnet_ids       = module.network.private_subnet_ids
  asg_db_private_subnet_id = module.security.asg_db_private_subnet_id
}

module "ansible" {
  source                = "./modules/ansible"
  min_size_ec2_instance = var.min_size_ec2_instance
  running_ec2_instances = module.compute.running_ec2_instances
  bastion_eip_ip        = module.network.bastion_eip_ip
  db_instance_endpoint  = module.database.db_instance_endpoint
  db_user               = var.db_user
  lb_dns_name           = module.loadbalancer.lb_dns_name
  efs_dns_name          = module.storage.efs_dns_name
}

module "storage" {
  source                = "./modules/storage"
  private_subnet_ids    = module.network.private_subnet_ids
  efs_security_group_id = module.security.efs_security_group_id
}
