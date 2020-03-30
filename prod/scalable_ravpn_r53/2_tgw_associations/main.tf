provider "aws" {
  region = var.aws-region
}

module "vpc1_association" {

source = "../../../modules/aws/tgw_associate"

vpc_name = var.vpc1-name
vpc_type = var.vpc1-type
tgw_name = var.tgw-name

}

module "tgw2_propagation" {

source = "../../../modules/aws/tgw_propagate"

vpc_name = var.vpc1-name
rt_name = var.tgw-rt1-name
tgw_name = var.tgw-name

}

