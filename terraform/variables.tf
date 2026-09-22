
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
