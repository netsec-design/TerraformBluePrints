provider "aws" {
  region = var.aws-region
} 


module "S2SVPNAttachment" {

source = "../../../modules/aws/tgw_vpn_attachment"

tgw_name = var.tgw-name
rt_name = var.tgw-rt1-name
s2svpn_bgp_asn = var.s2svpn-bgp-asn
s2svpn_endpoint_ip = var.s2svpn-endpoint-ip
s2sgw_name = var.s2s-gw-name
on_prem_cidr = var.on-prem-cidr

}