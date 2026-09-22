output "lb_target_group_arn" {
  description = "load balancer target group arn"
  value       = aws_lb_target_group.lb_target_group.arn
}

output "lb_arn" {
  description = "Load balancer arn"
  value       = aws_lb.load_balancer.arn
}

output "lb_dns_name" {
  description = "Load balancer dns name"
  value       = aws_lb.load_balancer.dns_name
}
