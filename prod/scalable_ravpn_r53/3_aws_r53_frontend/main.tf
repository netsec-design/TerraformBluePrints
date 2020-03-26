provider "aws" {
  region = var.aws-region
} 


module "AWS_R53" {

source = "../../../modules/aws/r53"

dns_name = var.dns-name
vpn_sub_domain = var.vpn-sub-domain

}