variable "min_size_ec2_instance" {
  description = "min size ec2 instance"
  type        = number
}

variable "running_ec2_instances" {
  description = "running ec2 instances"
  type        = list(string)
}

variable "bastion_eip_ip" {
  description = "bastion eip ip"
  type        = string
}

variable "db_instance_endpoint" {
  description = "db instance endpoint"
  type        = string
}

variable "db_pwd" {
  description = "db password"
  type        = string
}
