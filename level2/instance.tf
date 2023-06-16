data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "allows public traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["212.58.121.139/32"]
  }

  ingress {
    description = "WEB from home office"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["212.58.121.139/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr]
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "allows local private traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr]
  }
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[0]
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = "AWS1stINSTkey"
  associate_public_ip_address = true
  user_data                   = file("user-data.sh")

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[0]
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = "AWS1stINSTkey"

  tags = {
    Name = "${var.env_code}-private"
  }
}

output "public_ip_address" {
  value = aws_instance.public.public_ip
}
