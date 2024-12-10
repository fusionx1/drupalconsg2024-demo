output "security_group" {
  value = aws_security_group.lb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.df_tg.arn
}

output "http_listener" {
  value = aws_lb_listener.http_listener
}