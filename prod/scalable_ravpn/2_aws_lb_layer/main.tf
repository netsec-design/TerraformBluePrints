provider "aws" {
  region = var.aws-region

}


module "ExternalNLB" {
  source                   = "../../../modules/aws/nlb_enhanced"
  vpc_name                 = var.vpc1-name
  nlb_name                 = var.nlb1-name
  internal                 = var.nlb1-internal
  subnet_a_name            = var.public-subnet-a
  subnet_b_name            = var.public-subnet-b
  cross_zone               = var.nlb1-cross-zone
  tg_config                = var.nlb1-tg-config
  forwarding_config        = var.nlb1-fw-config 
}

module "InternalNLB" {
  source                   = "../../../modules/aws/nlb"
  nlb_name                 = var.nlb2-name
  internal                 = var.nlb2-internal
  vpc_name                 = var.vpc1-name
  subnet_a_name            = var.private-subnet-a
  subnet_b_name            = var.private-subnet-b
  target_grp_name          = var.nlb2-tg-group
  cross_zone               = var.nlb2-cross-zone
}