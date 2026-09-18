output "vpc_id" {
  description = "vpc Id"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  description = "public subnet ids"
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "private_subnet_ids" {
  description = "private subnet ids"
  value       = { for key, subnet in aws_subnet.private : key => subnet.id }
}
