terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }
  }

  required_version = ">=1.2.0"

  backend "s3" {
    bucket         = "terraform-rem-state-stor"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "remote-state"
  }
}


provider "aws" {
  region = "eu-central-1"
}
