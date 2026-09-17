######## DATA

data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

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

data "aws_cloudfront_cache_policy" "cloudfront_cache_policy" {
  name = var.cloudfront_managed_cache
}

######## LOCALS

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  subnets = {
    for index, availability_zone in local.availability_zones : availability_zone => {
      availability_zone = availability_zone
      public_cidr       = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, index * 2)
      private_cidr      = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, index * 2 + 1)
    }
  }
}

######## RESSOURCES

### VPC

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

###

### Subnets

resource "aws_subnet" "public" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.public_cidr

  tags = {
    Name = "${each.value.availability_zone}-public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.private_cidr

  tags = {
    Name = "${each.value.availability_zone}-private"
  }
}

###

### Security Group

resource "aws_security_group" "asg-public-subnet" {
  name        = "asg-public-subnet"
  description = "Aws security group for public subnet"
  vpc_id      = aws_vpc.main-vpc.id
}

resource "aws_security_group" "asg-auto-scaling-group-private-subnet" {
  name        = "asg-auto-scaling-group-private-subnet"
  description = "Aws security group for auto scaling group in private subnet"
  vpc_id      = aws_vpc.main-vpc.id
}

resource "aws_security_group" "asg-db-private-subnet" {
  name        = "asg-db-private-subnet"
  description = "Aws security group for database in private subnet"
  vpc_id      = aws_vpc.main-vpc.id
}

###

### Security group traffic rules

resource "aws_vpc_security_group_ingress_rule" "from_internet_to_lb_http" {
  description       = "Allow HTTP from internet"
  security_group_id = aws_security_group.asg-public-subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_internet_to_lb_https" {
  description       = "Allow HTTPS from internet"
  security_group_id = aws_security_group.asg-public-subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_lb_to_ec2_egress" {
  description                  = "Forward traffic from lb to ec2 instance"
  security_group_id            = aws_security_group.asg-public-subnet.id
  referenced_security_group_id = aws_security_group.asg-auto-scaling-group-private-subnet.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_lb_to_ec2_ingress" {
  description                  = "Allow HTTP from lb"
  security_group_id            = aws_security_group.asg-auto-scaling-group-private-subnet.id
  referenced_security_group_id = aws_security_group.asg-public-subnet.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_ec2_to_db_egress" {
  description                  = "Allow egress traffic from ec2 instance to db"
  security_group_id            = aws_security_group.asg-auto-scaling-group-private-subnet.id
  referenced_security_group_id = aws_security_group.asg-db-private-subnet.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_ec2_to_internet" {
  description       = "Allow egress traffic from ec2 instance to internet"
  security_group_id = aws_security_group.asg-auto-scaling-group-private-subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "from_ec2_to_db_ingress" {
  description                  = "Allow ingress traffic from ec2 to db"
  security_group_id            = aws_security_group.asg-db-private-subnet.id
  referenced_security_group_id = aws_security_group.asg-auto-scaling-group-private-subnet.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

###

### Key pair
resource "aws_key_pair" "key-5HASH" {
  key_name   = "key-5hash"
  public_key = file("../.keys/key-5hash.pub")
}

###

### Secret manager

# resource "aws_secretsmanager_secret" "db_pwd" {
#   name = "5HASH/db-pwd"
# }

# resource "aws_secretsmanager_secret_version" "db_pwd_version" {
#   secret_id     = aws_secretsmanager_secret.db_pwd.id
#   secret_string = var.db_pwd
# }

###

### ec2 Instance

# resource "aws_instance" "web" {
#   for_each               = aws_subnet.private
#   ami                    = data.aws_ami.debian_12.id
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.private[each.key].id
#   vpc_security_group_ids = [aws_security_group.asg-auto-scaling-group-private-subnet.id]
#   key_name               = aws_key_pair.key-5HASH.key_name
#   tags = {
#     Name    = "Name"
#     Project = "5HASH"
#     Role    = "webservers"
#   }
# }

### Launch template 

resource "aws_launch_template" "launch_template" {
  name                                 = "launch_template"
  image_id                             = data.aws_ami.debian_12.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance
  vpc_security_group_ids               = [aws_security_group.asg-auto-scaling-group-private-subnet.id]
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

resource "aws_autoscaling_group" "autoscaling_group" {
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
  target_group_arns   = [aws_lb_target_group.lb_target_group.arn]
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  launch_template {
    id = aws_launch_template.launch_template.id
  }

}


###

###

### Ansible Host

# resource "ansible_host" "ansible_host" {
#   name     = " à definir"
#   groups   = ["webservers"]
#   variables = {
#     ansible_host                 = 
#     ansible_user                 = "root"
#     ansible_ssh_private_key_file = "../.keys/key-5HASH"
#   }
# }

###

### Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "Internet_gateway"
  }
}

###

### NAT Gateway

resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.subnets

  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${each.value.availability_zone}-nat"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

###

### Eip

resource "aws_eip" "eip" {
  for_each = local.subnets
  domain   = "vpc"

  tags = {
    Name = "${each.value.availability_zone}-eip"
  }
}

###

### Route
# Public

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private

resource "aws_route_table" "private_route_table" {
  for_each = local.subnets
  vpc_id   = aws_vpc.main-vpc.id
  tags = {
    Name = "${each.value.availability_zone}-private-route-table"
  }
}

resource "aws_route" "private_route" {
  for_each               = local.subnets
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[each.key].id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

###

### CloudFront OAC

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

###

### CloudFront Distribution 

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = data.aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = var.s3_origin_id
  }

  enabled = true
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.s3_origin_id
    cache_policy_id        = data.aws_cloudfront_cache_policy.cloudfront_cache_policy.id
    viewer_protocol_policy = "allow-all"

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["FR"]
    }
  }

  # tags = {
  #   Environment = "production"
  # }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

###

### Firewall

resource "aws_wafv2_web_acl_rule" "Common_Rule_Set" {
  name        = "AWSManagedRulesCommonRuleSet"
  priority    = 10
  web_acl_arn = aws_wafv2_web_acl.firewall.arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesCommonRuleSet"
    sampled_requests_enabled   = true
  }
}


resource "aws_wafv2_web_acl_rule" "Known_Bad_Inputs" {
  name        = "AWSManagedRulesKnownBadInputsRuleSet"
  priority    = 20
  web_acl_arn = aws_wafv2_web_acl.firewall.arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl" "firewall" {
  name  = "${var.prefix}-${var.firewall_name}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  tags = {
    Name = "${var.prefix}-${var.firewall_name}"
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.prefix}-${var.firewall_name}"
    sampled_requests_enabled   = true
  }

  lifecycle {
    ignore_changes = [rule]
  }
}

###

### Load balancer 

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg-public-subnet.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  # tags = {
  #   Environment = "production"
  # }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id

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
