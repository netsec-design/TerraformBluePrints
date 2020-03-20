output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "tgw_id" {
  value = var.tgw_count > 0 ? aws_ec2_transit_gateway.tgw[0].id : var.tgw_id
}

output "vpc_name" {
  value = var.vpc_name
}

output "vpc_type" {
  value = var.vpc_type
}

output "tgw_subnet_ids" {
  value = values(aws_subnet.tgw_subnet)[*].id
}

output "private_subnet" {

  value = values(aws_subnet.private_subnet)[*].cidr_block
}


output "tgw_rt_id" {

  value = var.tgw_route_table_id == null ? [for rt in aws_ec2_transit_gateway_route_table.tr_rt: rt.id] : [var.tgw_route_table_id]

}