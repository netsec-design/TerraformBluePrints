data "aws_region" "current" {}

data "aws_ami" "cisco-asav-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["asav9-13-1-7-ENA-6836725a-4399-455a-bf58-01255e5213b8-ami-056e4d25f7577b998.4"]
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
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_mgmt_name}"]
  }
 }

 data "aws_subnet" "subnet_outside" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_outside_name}"]
  }
 }

 data "aws_subnet" "subnet_inside" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_inside_name}"]
  }
 }

   data "aws_lb_target_group" "nlb_target_grp" {
       for_each = var.lb_tg_name
        name = lookup(var.lb_tg_name, each.key)
    }

data "aws_route_table" "route_table_inside" {
  subnet_id = data.aws_subnet.subnet_inside.id
}

resource "aws_security_group" "SG-Allow-All-ASAv" {
  name        = "SG-Allow-All-ASAv-${var.instance_name}"
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
    "Name" = "SG-Allow-All-ASAv-${var.instance_name}"
  }
}

resource "aws_network_interface" "ASAv-Management" {
  subnet_id       = data.aws_subnet.subnet_mgmt.id
  security_groups = ["${aws_security_group.SG-Allow-All-ASAv.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_mgmt_name}"
  }
}
resource "aws_network_interface" "ASAv-Outside" {
  subnet_id       = data.aws_subnet.subnet_outside.id
  security_groups = ["${aws_security_group.SG-Allow-All-ASAv.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_outside_name}-Outside"
  }
}
resource "aws_network_interface" "ASAv-Inside" {
  subnet_id       = data.aws_subnet.subnet_inside.id
  security_groups = ["${aws_security_group.SG-Allow-All-ASAv.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_inside_name}-Inside"
  }
}

resource "aws_instance" "ASAv" {
  ami           = data.aws_ami.cisco-asav-lookup.id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${var.instance_name}-${var.availability_zone}"
  }

  user_data = file("${var.template_file}")

  availability_zone = "${data.aws_region.current.name}${var.availability_zone}"


  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.ASAv-Management.id
  }

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.ASAv-Outside.id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.ASAv-Inside.id
  }
}

resource "aws_eip" "instance-public-ip" {

  count = var.public_ip ? 1 : 0

  network_interface = aws_network_interface.ASAv-Outside.id
  vpc      = true

}

resource "aws_alb_target_group_attachment" "ASAv_attach_tg" {

  for_each = var.lb_tg_name
  target_group_arn = data.aws_lb_target_group.nlb_target_grp[each.key].id
  target_id        = tolist(aws_network_interface.ASAv-Outside.private_ips)[0]
  port             = each.key
}


resource "aws_route" "private_default_to_asa" {
  route_table_id            = data.aws_route_table.route_table_inside.id
  destination_cidr_block    = "0.0.0.0/0"
  network_interface_id =  aws_network_interface.ASAv-Inside.id
}