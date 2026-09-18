
### Secret manager

resource "aws_secretsmanager_secret" "db_pwd" {
  name = "5HASH/db-pwd"
}

resource "aws_secretsmanager_secret_version" "db_pwd_version" {
  secret_id     = aws_secretsmanager_secret.db_pwd.id
  secret_string = var.db_pwd
}

###
