variable "asg_public_subnet_id" {
  description = "public subnet id"
  type        = string
}

variable "public_subnet_ids" {
  description = "public subnet id"
  type        = map(string)
}

variable "vpc_id" {
  description = "vpc Id"
  type        = string
}
