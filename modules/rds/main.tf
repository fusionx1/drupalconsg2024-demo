resource "random_string" "rds_username" {
  length = 14
  special = false
}

resource "random_string" "rds_password" {
  length           = 20
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  tags        = var.tags
  vpc_id      = var.vpc.id

  ingress {
    description     = "Allow MySQL traffic"
    from_port       = "3306"
    to_port         = "3306"
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

resource "aws_db_subnet_group" "drupal_rds_group" {
  name        = "drupal-fargate"
  subnet_ids  = var.subnet_ids
  description = "The DB group for drupal-fargate project"

  tags = var.tags
}

resource "aws_db_instance" "rds" {
  identifier                 = "drupal-fargate"
  instance_class             = "db.t3.micro"
  db_name                    = "drupal"
  engine                     = "mariadb"
  engine_version             = "10.6"
  username                   = "drupaluser"
  password                   = random_string.rds_password.result
  port                       = 3306
  multi_az                   = false
  network_type               = "IPV4"
  publicly_accessible        = true
  auto_minor_version_upgrade = true
  db_subnet_group_name       = aws_db_subnet_group.drupal_rds_group.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  storage_type               = "gp3"
  allocated_storage          = 20
  skip_final_snapshot        = true
}