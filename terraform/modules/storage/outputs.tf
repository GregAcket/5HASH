output "efs_dns_name" {
  description = "EFS dns name"
  value       = aws_efs_file_system.prestashop.dns_name
}
