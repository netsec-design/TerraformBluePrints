data "aws_region" "current" {}

data "aws_ec2_transit_gateway" "tgw" {
  filter {
    name   = "tag:Name"
    values = ["${var.tgw_name}"]
  }
    filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ec2_transit_gateway_vpc_attachment" "attach" {

    filter{
        name = "transit-gateway-id"
        values = ["${data.aws_ec2_transit_gateway.tgw.id}"]
    }

    filter{
        name = "tag:Name"
        values = ["TGW-${var.vpc_name}"]
    }   
    
}

data "aws_ec2_transit_gateway_route_table" "tgw_rt" {

    filter{
        name = "transit-gateway-id"
        values = ["${data.aws_ec2_transit_gateway.tgw.id}"]
    }

    filter{
        name = "tag:Type"
        values = ["${var.vpc_type}"]
    }   
    
}

resource "aws_ec2_transit_gateway_route_table_association" "rta" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.attach.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tgw_rt.id
}