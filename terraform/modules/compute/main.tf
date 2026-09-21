######## DATA

data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

######## RESSOURCES

### Launch template 


resource "aws_launch_template" "launch_template" {
  name                                 = "launch_template"
  image_id                             = data.aws_ami.debian_12.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance
  vpc_security_group_ids               = [var.asg_auto_scaling_group_private_subnet_id]
  key_name                             = aws_key_pair.key-5HASH.key_name
  user_data = base64encode(<<-EOF
  #!/bin/bash
  echo "OK from $(hostname)" > /tmp/index.html
  cd /tmp
  nohup python3 -m http.server 80 > /var/log/user-data-http.log 2>&1 &
  EOF
  )
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "launch_template"
    }
  }
}

###

### Auto scalling group

resource "aws_autoscaling_group" "autoscaling_group" {
  min_size                  = 2
  max_size                  = 3
  desired_capacity          = 2
  health_check_grace_period = 150
  health_check_type         = "ELB"
  target_group_arns         = [var.lb_target_group_arn]
  vpc_zone_identifier       = [for subnet in var.private_subnet_ids : subnet]

  launch_template {
    id = aws_launch_template.launch_template.id
  }
}

###

### Key pair

resource "aws_key_pair" "key-5HASH" {
  key_name   = "key-5hash"
  public_key = file("../${path.root}/.keys/key-5hash.pub")
}

###
