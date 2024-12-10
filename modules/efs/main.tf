resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security Group for EFS"
  tags        = var.tags
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow NFS traffic"
    from_port       = "2049"
    to_port         = "2049"
    protocol        = "tcp"
    security_groups = [var.ecs_sg]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_efs_file_system" "files" {
  encrypted = true
  tags      = var.tags
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "name" {
  for_each        = var.subnets
  file_system_id  = aws_efs_file_system.files.id
  security_groups = [aws_security_group.efs_sg.id]
  subnet_id       = each.key
}

resource "aws_efs_access_point" "files" {
  file_system_id = aws_efs_file_system.files.id
  posix_user {
    uid = 82
    gid = 82
  }
  root_directory {
    creation_info {
      owner_uid   = 82
      owner_gid   = 82
      permissions = 755
    }
    path = "/files"
  }

}