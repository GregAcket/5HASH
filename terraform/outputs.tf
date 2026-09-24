output "lb_dns_name" {
  description = "Load balancer dns name"
  value       = module.loadbalancer.lb_dns_name
}

output "bastion_eip_ip" {
  description = "bastion eip ip"
  value       = module.network.bastion_eip_ip
}


output "db_instance_endpoint" {
  description = "db instance endpoint"
  value       = module.database.db_instance_endpoint
}
