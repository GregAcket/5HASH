
### Secret manager

resource "aws_secretsmanager_secret" "db_pwd" {
  name                    = "5HASH/db-pwd"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_pwd_version" {
  secret_id     = aws_secretsmanager_secret.db_pwd.id
  secret_string = var.db_pwd
}

###

### DB

resource "aws_db_instance" "default" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_pwd
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [var.asg_db_private_subnet_id]
  storage_encrypted      = true
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [for subnet in var.private_subnet_ids : subnet]

  tags = {
    Name = "My DB subnet group"
  }
}

###
