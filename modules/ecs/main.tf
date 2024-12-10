data "aws_ecr_repository" "ecr_repo" {
  name = "drupal-fargate"
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

data "aws_caller_identity" "current" { }

locals {
  account_id = data.aws_caller_identity.current.account_id
  ecsTaskExecutionRole = data.aws_iam_role.ecsTaskExecutionRole.arn != "" ? data.aws_iam_role.ecsTaskExecutionRole.arn : "arn:aws:iam::${local.account_id}:role/ecsTaskExecutionRole"
  ecr_repo_url = data.aws_ecr_repository.ecr_repo.repository_url
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "The security group for the ECS traffic."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb_sg]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "DrupalCluster"
  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name                              = "drupal-fargate-service"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.drupal.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60
  enable_execute_command            = true

  load_balancer {
    target_group_arn = var.lb_tg_arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = var.vpc_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  triggers = {
    redeployment = timestamp()
  }

  wait_for_steady_state = true

}


resource "aws_ecs_task_definition" "drupal" {
  family                   = "drupal-fargate"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "php"
      image     = "${local.ecr_repo_url}:php-latest"
      cpu       = 512
      memory    = 1536
      essential = true
      mountPoints : [{
        sourceVolume  = "drupal-files",
        containerPath = "/var/www/html/web/sites/default/files"
      }]
    },
    {
      name   = "nginx"
      image  = "${local.ecr_repo_url}:nginx-latest"
      cpu    = 512
      memory = 512
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
        }
      ]
      essential = true,
      mountPoints = [{
        sourceVolume  = "drupal-files",
        containerPath = "/var/www/html/web/sites/default/files"
      }]
    }
  ])
  task_role_arn      = local.ecsTaskExecutionRole
  execution_role_arn = local.ecsTaskExecutionRole

  volume {
    name = "drupal-files"
    efs_volume_configuration {
      file_system_id          = var.efs_fs_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = var.efs_access_point
        iam             = "ENABLED"
      }
    }
  }

}
