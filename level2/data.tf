data "terraform_remote_state" "level1" {
  backend = "s3"
  config = {
    bucket = "terraform-rem-state-stor"
    key    = "level1.tfstate"
    region = "eu-central-1"
  }
}
