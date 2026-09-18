variable "private_subnet_ids" {
  description = "private subnet ids"
  type        = map(string)
}

variable "asg_auto_scaling_group_private_subnet_id" {
  description = "asg auto scaling group private subnet id"
  type        = string
}

variable "lb_target_group_arn" {
  description = "load balancer target group arn"
  type        = string
}

variable "instance" {
  description = "instance ec2"
  type        = string
}
