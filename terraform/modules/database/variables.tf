
variable "db_pwd" {
  description = "db password"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "db username"
  type        = string
}

variable "private_subnet_ids" {
  description = "private subnet ids"
  type        = map(string)
}

variable "asg_db_private_subnet_id" {
  description = "db private subnet security group id"
  type        = string
}

variable "ansible_vault_secrets_yaml" {
  description = "ansible vault secrets yaml"
  type        = string
}
