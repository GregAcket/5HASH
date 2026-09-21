variable "vpc_id" {
  description = "vpc Id"
  type        = string
}

variable "prefix" {
  type    = string
  default = "5hash"
}
variable "firewall_name" {
  type    = string
  default = "firewall"
}

variable "lb_arn" {
  description = "Load balancer arn"
  type        = string
}
