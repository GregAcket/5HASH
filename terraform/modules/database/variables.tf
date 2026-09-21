
variable "db_pwd" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type = string
}

variable "private_subnet_ids" {
  description = "private subnet ids"
  type        = map(string)
}

variable "asg_db_private_subnet_id" {
  type = string
}
