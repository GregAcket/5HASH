output "asg_public_subnet_id" {
  description = "public subnet security group id"
  value       = aws_security_group.asg_public_subnet.id
}

output "asg_auto_scaling_group_private_subnet_id" {
  description = "auto scaling group private subnet security group id"
  value       = aws_security_group.asg_auto_scaling_group_private_subnet.id
}

output "asg_db_private_subnet_id" {
  description = "db private subnet security group id"
  value       = aws_security_group.asg_db_private_subnet.id
}

output "asg_bastion_id" {
  description = "bastion security group id"
  value       = aws_security_group.bastion.id
}
