resource "aws_security_group" "load-balancer" {
  name        = "${var.env_code}-load-balancer"
  description = "Allows HTTP to LB"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "HTTP from the world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.global_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr]
  }
}

resource "aws_lb_target_group" "main" {
  name     = var.env_code
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.level1.outputs.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
  }
}

resource "aws_lb" "main" {
  name               = var.env_code
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = data.terraform_remote_state.level1.outputs.public_subnet_id

  tags = {
    Name = var.env_code
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = length(aws_instance.private)

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.private[count.index].id
  port             = 80
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
