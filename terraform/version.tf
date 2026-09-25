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
      source  = "hashicorp/http" #pour aller chercher l'ip de l'admin pour la co en ssh au bastion
      version = "~> 3.6"
    }
  }
}
