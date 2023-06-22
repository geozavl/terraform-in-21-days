module "as" {
  source = "../modules/as"

  env_code         = var.env_code
  target_group_arn = module.lb.target_group_arn
  subnet_id        = data.terraform_remote_state.level1.outputs.private_subnet_id
  global_cidr      = var.global_cidr
  vpc_id           = data.terraform_remote_state.level1.outputs.vpc_id
  lb_sg            = module.lb.lb_sg
  ami_id           = data.aws_ami.amazonlinux.id
}
