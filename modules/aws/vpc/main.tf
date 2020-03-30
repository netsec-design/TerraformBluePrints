data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "tgw_subnet" {

  vpc_id            = var.subnet_vpc_id == null ? null : var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "tgw"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "private_subnet" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "priv"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "private_subnet_tgw" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "priv_tgw"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "public_subnet" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "pub"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_subnet" "mgmt_subnet" {

  vpc_id            = var.subnet_vpc_id
  for_each = {for network in var.networks:  network.name => network if network.ntype == "mgmt"}

  cidr_block = each.value.cidr
  availability_zone = "${data.aws_region.current.name}${each.value.az}"

  tags = {
    Name = "${each.value.name}"
    Type = "${each.value.ntype}"
  }
}

resource "aws_route_table" "rt_pub" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "pub"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${each.value.name}"
  }
}

resource "aws_route_table" "rt_priv_tgw" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "priv_tgw"}

  route {
    cidr_block = var.main_cidr
    gateway_id = aws_ec2_transit_gateway.tgw[0].id
  }

  route {
    cidr_block = var.on_prem_cidr
    gateway_id = aws_ec2_transit_gateway.tgw[0].id
  }

  tags = {
    Name = "${each.value.name}"
  }

   depends_on = [aws_ec2_transit_gateway.tgw, aws_ec2_transit_gateway_vpc_attachment.tgw_attach]
}

resource "aws_route_table" "rt_priv" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "priv"}
 

  tags = {
    Name = "${each.value.name}"
  }

   depends_on = [aws_ec2_transit_gateway.tgw, aws_ec2_transit_gateway_vpc_attachment.tgw_attach]
}

resource "aws_route_table" "rt_tgw" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "tgw"}


  tags = {
    Name = "${each.value.name}"
  }
}

resource "aws_route_table" "rt_mgmt" {
  vpc_id = var.subnet_vpc_id
  for_each = {for rt in var.route_tables:  rt.name => rt if rt.rtype == "mgmt"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    #gateway_id = var.tgw_attached == false ? aws_internet_gateway.igw.id : aws_ec2_transit_gateway.tgw[0].id
  }

  tags = {
    Name = "${each.value.name}"
  }

  depends_on = [aws_ec2_transit_gateway.tgw, aws_ec2_transit_gateway_vpc_attachment.tgw_attach]
}

resource "aws_route_table_association" "as_pub" {

  
  count = length([for network in var.networks: null if network.ntype == "pub"])

  route_table_id = values(aws_route_table.rt_pub)[0].id
  subnet_id      = values(aws_subnet.public_subnet)[count.index].id

}

resource "aws_route_table_association" "as_priv" {

  count = length([for network in var.networks: null if network.ntype == "priv"])

  route_table_id = values(aws_route_table.rt_priv)[count.index].id
  subnet_id      = values(aws_subnet.private_subnet)[count.index].id

}

resource "aws_route_table_association" "as_priv_tgw" {

  count = length([for network in var.networks: null if network.ntype == "priv_tgw"])

  route_table_id = values(aws_route_table.rt_priv_tgw)[count.index].id
  subnet_id      = values(aws_subnet.private_subnet_tgw)[count.index].id

}

resource "aws_route_table_association" "as_tgw" {

  count = length([for network in var.networks: null if network.ntype == "tgw"])

  route_table_id = values(aws_route_table.rt_tgw)[0].id
  subnet_id      = values(aws_subnet.tgw_subnet)[count.index].id

}

resource "aws_route_table_association" "as_mgmt" {

  count = length([for network in var.networks: null if network.ntype == "mgmt"])

  route_table_id = values(aws_route_table.rt_mgmt)[0].id
  subnet_id      = values(aws_subnet.mgmt_subnet)[count.index].id

}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.subnet_vpc_id

  tags = {
    Name = "${var.igw_name}"
  }
}


resource aws_ec2_transit_gateway "tgw" {
  count = var.tgw_count
  description = var.tgw_name
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "${var.tgw_name}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach" {

  count = var.tgw_attached == true ? 1 : 0

  subnet_ids         = values(aws_subnet.tgw_subnet)[*].id
  transit_gateway_id = var.tgw_id == null ? aws_ec2_transit_gateway.tgw[0].id : var.tgw_id
  vpc_id             = aws_vpc.vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "TGW-${var.vpc_name}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tr_rt" {
  count = var.tgw_route_tables != null ? length({for tr_rt in var.tgw_route_tables:  tr_rt.name => tr_rt}) : 0
  transit_gateway_id = var.tgw_id == null ? aws_ec2_transit_gateway.tgw[0].id : var.tgw_id

    tags = {
      Name = "${var.tgw_route_tables[count.index].name}"
      Type = "${var.tgw_route_tables[count.index].type}"
  }
}