output "instance_bastion_id" {
  description = "instance bastion id"
  value       = aws_instance.bastion_instance.id
}

output "running_ec2_instances" {
  description = "running ec2 instances"
  value       = data.aws_instances.running_ec2_instances.private_ips
}


