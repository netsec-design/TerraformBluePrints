provider "aws" {
  region = var.aws-region
} 


module "ASAv_Instances" {

source = "../../../modules/aws/r53"

dns_name = var.dns-name
vpn_sub_domain = var.vpn-sub-domain

}