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
  name        = "public"
  description = "allows public traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["178.221.100.11/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.global_cidr]
  }
}

resource "aws_security_group" "private" {
  name        = "private"
  description = "allows local private traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from home office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = "AWS1stINSTkey"
  associate_public_ip_address = true

  tags = {
    Name = "public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = "AWS1stINSTkey"

  tags = {
    Name = "private"
  }
}

output "public_ip_address" {
  value = aws_instance.public.public_ip
}