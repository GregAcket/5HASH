variable "private_subnet_ids" {
  description = "private subnet ids"
  type        = map(string)
}

variable "efs_security_group_id" {
  description = "EFS security group id"
  type        = string
}
