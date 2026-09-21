### Security Group

resource "aws_security_group" "asg_public_subnet" {
  name        = "asg-public-subnet"
  description = "Aws security group for public subnet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "asg_auto_scaling_group_private_subnet" {
  name        = "asg-auto-scaling-group-private-subnet"
  description = "Aws security group for auto scaling group in private subnet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "asg_db_private_subnet" {
  name        = "asg-db-private-subnet"
  description = "Aws security group for database in private subnet"
  vpc_id      = var.vpc_id
}

###

### Security group traffic rules

resource "aws_vpc_security_group_ingress_rule" "from_internet_to_lb_http" {
  description       = "Allow HTTP from internet"
  security_group_id = aws_security_group.asg_public_subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_internet_to_lb_https" {
  description       = "Allow HTTPS from internet"
  security_group_id = aws_security_group.asg_public_subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_lb_to_ec2_egress" {
  description                  = "Forward traffic from lb to ec2 instance"
  security_group_id            = aws_security_group.asg_public_subnet.id
  referenced_security_group_id = aws_security_group.asg_auto_scaling_group_private_subnet.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from_lb_to_ec2_ingress" {
  description                  = "Allow HTTP from lb"
  security_group_id            = aws_security_group.asg_auto_scaling_group_private_subnet.id
  referenced_security_group_id = aws_security_group.asg_public_subnet.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_ec2_to_db_egress" {
  description                  = "Allow egress traffic from ec2 instance to db"
  security_group_id            = aws_security_group.asg_auto_scaling_group_private_subnet.id
  referenced_security_group_id = aws_security_group.asg_db_private_subnet.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "from_ec2_to_internet" {
  description       = "Allow egress traffic from ec2 instance to internet"
  security_group_id = aws_security_group.asg_auto_scaling_group_private_subnet.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "from_ec2_to_db_ingress" {
  description                  = "Allow ingress traffic from ec2 to db"
  security_group_id            = aws_security_group.asg_db_private_subnet.id
  referenced_security_group_id = aws_security_group.asg_auto_scaling_group_private_subnet.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

###

### Firewall

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

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = var.lb_arn
  web_acl_arn  = aws_wafv2_web_acl.firewall.arn
}

###
