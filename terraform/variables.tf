
variable "region" {
  description = "Region name"
  type        = string
  default     = "eu-west-3"
}

variable "instance" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_pwd" {
  description = "db password"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "db user"
  type        = string
  default     = "user"
}

variable "min_size_ec2_instance" {
  description = "min size ec2 instance"
  type        = number
  default     = 2
}

variable "ansible_vault_secrets_yaml" {
  description = "ansible vault secrets yaml"
  type        = string
  default     = "./ansible/group_vars/all/vault.yml"
}
