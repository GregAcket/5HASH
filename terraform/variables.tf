variable "prefix" {
  type    = string
  default = "5hash"
}
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

variable "bucket_name" {
  type    = string
  default = "5hash-bucket"
}

variable "s3_origin_id" {
  type    = string
  default = "s3_origin_id"
}

variable "cloudfront_managed_cache" {
  type    = string
  default = "Managed-CachingOptimized"
}

