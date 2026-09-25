output "lb_target_group_arn" {
  description = "load balancer target group arn"
  value       = aws_lb_target_group.lb_target_group.arn
}

output "lb_target_group_arn_suffix" {
  description = "load balancer target group arn suffix"
  value       = aws_lb_target_group.lb_target_group.arn_suffix
}

output "lb_arn" {
  description = "Load balancer arn"
  value       = aws_lb.load_balancer.arn
}
output "lb_arn_suffix" {
  description = "Load balancer arn suffix"
  value       = aws_lb.load_balancer.arn_suffix
}

output "lb_dns_name" {
  description = "Load balancer dns name"
  value       = aws_lb.load_balancer.dns_name
}
