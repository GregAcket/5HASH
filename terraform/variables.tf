
variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "instance" {
  type    = string
  default = "t3.micro"
}

variable "db_pwd" {
  type      = string
  sensitive = true
}

