### Provider

terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.5"
    }
  }
}

###

### Ansible Host

resource "ansible_host" "ansible_host_ec2" {
  count  = var.min_size_ec2_instance
  name   = "web-${count.index}"
  groups = ["webservers"]
  variables = {
    ansible_host                 = var.running_ec2_instances[count.index]
    ansible_user                 = "admin"
    ansible_ssh_private_key_file = ".keys/key-5hash"
    ansible_ssh_common_args      = "-o ProxyCommand='ssh -i .keys/key-5hash -W %h:%p admin@${var.bastion_eip_ip}'"
    endpoint_rds                 = var.db_instance_endpoint
    db_password                  = var.db_pwd
  }
}

resource "ansible_host" "ansible_host_bastion" {
  name   = "bastion"
  groups = ["bastion"]
  variables = {
    ansible_host                 = var.bastion_eip_ip
    ansible_user                 = "admin"
    ansible_ssh_private_key_file = ".keys/key-5hash"

  }
}

###
