data "aws_region" "current" {}

data "aws_ec2_transit_gateway" "tgw" {
  filter {
    name   = "tag:Name"
    values = [var.tgw_name]
  }
    filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ec2_transit_gateway_route_table" "tgw_rt" {

    filter{
        name = "transit-gateway-id"
        values = ["${data.aws_ec2_transit_gateway.tgw.id}"]
    }
    filter{
        name = "tag:Name"
        values = ["${var.rt_name}"]
    }   
}


resource "aws_customer_gateway" "vpngw" {
  bgp_asn    = var.s2svpn_bgp_asn
  ip_address = var.s2svpn_endpoint_ip
  type       = "ipsec.1"

 tags = {
    Name = "${var.s2sgw_name}"
  }
}

resource "aws_vpn_connection" "s2svpn" {
  customer_gateway_id = aws_customer_gateway.vpngw.id
  transit_gateway_id  = data.aws_ec2_transit_gateway.tgw.id
  type                = aws_customer_gateway.vpngw.type
  static_routes_only  = true

   tags = {
    Name = "TGW-${var.s2sgw_name}"
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "vpnattachment" {
  transit_gateway_id = "${data.aws_ec2_transit_gateway.tgw.id}"
  vpn_connection_id  = "${aws_vpn_connection.s2svpn.id}"

}


resource "aws_ec2_transit_gateway_route" "tgw_route_inject" {
  destination_cidr_block         = var.on_prem_cidr
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.vpnattachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "rta" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.vpnattachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw_rt.id
}