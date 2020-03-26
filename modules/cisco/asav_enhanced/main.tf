data "aws_region" "current" {}

data "aws_ami" "cisco-asav-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["${var.asa_ami_id}"]
  }

  owners = ["${var.ami_owner_id}"]
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_subnet" "subnet_mgmt" {
  for_each = var.subnet_mgmt_name
  filter{   
   name = "tag:Name"
   values = [lookup(var.subnet_mgmt_name, each.key)]
  }
 }

 data "aws_subnet" "subnet_outside" {
  for_each = var.subnet_outside_name
  filter{   
   name = "tag:Name"
   values = [lookup(var.subnet_outside_name, each.key)]
  }
 }

 data "aws_subnet" "subnet_inside" {
  for_each = var.subnet_inside_name
  filter{   
   name = "tag:Name"
   values = [lookup(var.subnet_inside_name, each.key)]
  }
 }

data "aws_lb_target_group" "nlb_target_grp" {
  for_each = var.lb_tg_name
        name = lookup(var.lb_tg_name, each.key)
}

data "aws_route_table" "route_table_inside" {
  for_each = var.asa_instances
  subnet_id = lookup(data.aws_subnet.subnet_inside, lookup(lookup(var.asa_instances, each.key),"availability-zone")).id
}

data "aws_route53_zone" "r53" {
  count = var.dns_name == null ? 0: 1
  name         = var.dns_name
  private_zone = false
}

locals  {

flat_lb = flatten([for asa_key, asa in var.asa_instances: [
  for lb in data.aws_lb_target_group.nlb_target_grp: [{
    asa_key = asa_key
    key = "${asa_key}.${lookup(var.lb_tg_name, lb.port)}"
    lb = lb.id
    private_ip = tolist(lookup(aws_network_interface.ASAv-Outside, asa_key).private_ips)[0]
    port = lb.port
  } 
]
]])

}

resource "aws_security_group" "SG-Allow-All-ASAv" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  name        = "SG-Allow-All-ASAv-${each.key}"
  description = "Security Group to allow all traffic"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "SG-Allow-All-ASAv-${each.key}"
  }
}

resource "aws_network_interface" "ASAv-Management" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  subnet_id       = lookup(data.aws_subnet.subnet_mgmt, lookup(lookup(var.asa_instances, each.key),"availability-zone")).id
  security_groups = ["${lookup(aws_security_group.SG-Allow-All-ASAv, each.key).id}"]
  source_dest_check = false
  tags = {
    "Name" = "${each.key}-${var.subnet_mgmt_name[lookup(lookup(var.asa_instances, each.key),"availability-zone")]}"
  }
}
resource "aws_network_interface" "ASAv-Outside" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  subnet_id       = lookup(data.aws_subnet.subnet_outside, lookup(lookup(var.asa_instances, each.key),"availability-zone")).id
  security_groups = ["${lookup(aws_security_group.SG-Allow-All-ASAv, each.key).id}"]
  source_dest_check = false
  tags = {
    "Name" = "${each.key}-${var.subnet_outside_name[lookup(lookup(var.asa_instances, each.key),"availability-zone")]}-Outside"
  }
}
resource "aws_network_interface" "ASAv-Inside" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  subnet_id       = lookup(data.aws_subnet.subnet_inside, lookup(lookup(var.asa_instances, each.key),"availability-zone")).id
  security_groups = ["${lookup(aws_security_group.SG-Allow-All-ASAv, each.key).id}"]
  source_dest_check = false
  tags = {
    "Name" = "${each.key}-${var.subnet_inside_name[lookup(lookup(var.asa_instances, each.key),"availability-zone")]}-Inside"
  }
}

resource "aws_instance" "ASAv" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  ami           = data.aws_ami.cisco-asav-lookup.id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${each.key}-${lookup(lookup(var.asa_instances, each.key),"availability-zone")}"
  }

  user_data = file("${lookup(lookup(var.asa_instances, each.key),"template-file")}")

  availability_zone = "${data.aws_region.current.name}${lookup(lookup(var.asa_instances, each.key),"availability-zone")}"


  network_interface {
    device_index = 0
    network_interface_id = lookup(aws_network_interface.ASAv-Management, each.key).id
  }

  network_interface {
    device_index = 1
    network_interface_id = lookup(aws_network_interface.ASAv-Outside, each.key).id
  }

  network_interface {
    device_index = 2
    network_interface_id = lookup(aws_network_interface.ASAv-Inside, each.key).id
  }
}

resource "aws_eip" "instance-public-ip" {

  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key}
  network_interface = lookup(aws_network_interface.ASAv-Outside, each.key).id
  vpc      = true

}


resource "aws_alb_target_group_attachment" "ASAv_attach_tg" {

  for_each = {for tg in local.flat_lb: tg.key => tg}
  target_group_arn = each.value.lb
  target_id         = each.value.private_ip
  port             = each.value.port

} 


resource "aws_route" "private_default_to_asa" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key if lookup(var.asa_instances, asa_key).default-to-private == true }
  route_table_id            = lookup(data.aws_route_table.route_table_inside, each.key).id
  destination_cidr_block    = "0.0.0.0/0"
  network_interface_id = lookup(aws_network_interface.ASAv-Inside, each.key).id
}

resource "aws_route53_health_check" "hc" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key if lookup(var.asa_instances, asa_key).attach-to-dns == true }
  failure_threshold = "5"
  ip_address              = lookup(aws_eip.instance-public-ip, each.key).public_ip
  fqdn                    = lookup(aws_eip.instance-public-ip, each.key).public_dns
  port              = var.r53_health_check_port
  request_interval  = "30"
  resource_path     = "/"
  search_string     = "+CSCOE+"
  type              = "HTTPS_STR_MATCH"
  measure_latency = true

    tags = {
    "Name" = each.key
  }
}

resource "aws_route53_record" "vpn_record" {
  for_each = {for asa_key, asa in var.asa_instances: asa_key => asa_key if lookup(var.asa_instances, asa_key).attach-to-dns == true }
  zone_id = data.aws_route53_zone.r53[0].zone_id
  name    = var.vpn_subdomain
  type    = "A"
  ttl     = "5"
  health_check_id = lookup(aws_route53_health_check.hc, each.key).id

  weighted_routing_policy {
    weight = lookup(lookup(var.asa_instances, each.key),"weight")
  }

  set_identifier = each.key
  records        = [lookup(aws_eip.instance-public-ip, each.key).public_ip]
}