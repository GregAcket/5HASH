variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "instance" {
  type    = string
  default = "t3.micro"
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}
