terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}
