resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "allows local private traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "WEB from LB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb_sg]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = [var.global_cidr]
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.env_code}-"
  image_id             = var.ami_id
  instance_type        = "t3.micro"
  security_groups      = [aws_security_group.private.id]
  user_data            = file("${path.module}/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.main.name

}

resource "aws_autoscaling_group" "main" {
  name             = var.env_code
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  target_group_arns    = [var.target_group_arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = var.subnet_id

  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "main" {
  name                = var.env_code
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "main" {
  name = var.env_code
  role = aws_iam_role.main.name
}
