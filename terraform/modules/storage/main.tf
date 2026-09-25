resource "aws_efs_file_system" "prestashop" {
  encrypted = true

  tags = {
    Name = "prestashop-efs"
  }
}

resource "aws_efs_mount_target" "prestashop" {
  for_each = var.private_subnet_ids

  file_system_id  = aws_efs_file_system.prestashop.id
  subnet_id       = each.value
  security_groups = [var.efs_security_group_id]
}
