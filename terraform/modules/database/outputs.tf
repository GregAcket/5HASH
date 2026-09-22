
output "db_instance_endpoint" {
  description = "db instance endpoint"
  value       = aws_db_instance.default.endpoint
}
