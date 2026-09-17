variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "instance" {
  type    = string
  default = "t3.micro"
}
variable "bucket_name" {
  type    = string
  default = "5HASH-bucket"
}

variable "db_pwd" {
  type      = string
  sensitive = true
}
