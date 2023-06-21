output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "lb_sg" {
  value = aws_security_group.load-balancer.id
}
