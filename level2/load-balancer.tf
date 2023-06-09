module "lb" {
  source = "../modules/lb"

  env_code    = var.env_code
  global_cidr = var.global_cidr
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id
  subnet_id   = data.terraform_remote_state.level1.outputs.public_subnet_id
}
