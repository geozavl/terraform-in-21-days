data "terraform_remote_state" "level1" {
  backend = "s3"
  config = {
    bucket = "terraform-rem-state-stor"
    key    = "level1.tfstate"
    region = "eu-central-1"
  }
}

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
