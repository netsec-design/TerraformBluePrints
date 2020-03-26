provider "aws" {
  region = var.aws-region
} 
 
 
module "ASAv_Instances" {

source = "../../../modules/cisco/firepower/asav_enhanced"

vpc_name = var.vpc1-name
ami_owner_id = var.ami-owner
asa_ami_id = var.asa-ami-id
instance_size = var.asav-instance-size
key_name = var.ssh-key-name
subnet_mgmt_name = {
  "a" = var.mgmt-subnet-a,
  "b" = var.mgmt-subnet-b
}
subnet_outside_name = {
  "a" = var.public-subnet-a,
  "b" =  var.public-subnet-b
}
subnet_inside_name = {
  "a" = var.private-subnet-a,
  "b" = var.private-subnet-b

}

asa_instances = var.asa-instances
dns_name = var.dns-name
vpn_subdomain = var.vpn-sub-domain
r53_health_check_port = var.r53-health-check-port
}