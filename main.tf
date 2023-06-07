terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }
  }

  required_version = ">=1.2.0"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zone)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "public${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zone)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "nat" {
  count = length(var.availability_zone)
  vpc   = true

  tags = {
    Name = "nat${count.index}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zone)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.global_cidr
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zone)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.global_cidr
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zone)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zone)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
