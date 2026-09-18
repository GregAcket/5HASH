### Load balancer 

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  load_balancer_type = "application"
  security_groups    = [var.asg_public_subnet_id]
  subnets            = [for subnet in var.public_subnet_ids : subnet]

  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    timeout = 6
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

###
