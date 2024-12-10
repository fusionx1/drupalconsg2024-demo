resource "aws_security_group" "lb_sg" {
  name        = "alb-sg"
  description = "Security group for the load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow http traffic"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_lb" "alb" {
  name               = "drupal-fargate-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in keys(var.subnets) : subnet]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.df_tg.arn
  }
}

resource "aws_lb_target_group" "df_tg" {
  name        = "df-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    enabled  = true
    path     = "/health"
    interval = 60
    matcher  = "200"
  }
}