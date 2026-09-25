variable "public_subnet_ids" {
  description = "public subnet id"
  type        = map(string)
}

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


variable "asg_bastion_id" {
  description = "asg bastion id"
  type        = string
}

variable "min_size_ec2_instance" {
  description = "min size ec2 instance"
  type        = number
}
variable "lb_arn_suffix" {
  description = "lb arn suffix"
  type        = string
}

variable "lb_target_group_arn_suffix" {
  description = "lb target group arn suffix"
  type        = string
}
