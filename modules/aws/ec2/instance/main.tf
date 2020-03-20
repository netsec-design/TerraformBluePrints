data "aws_region" "current" {}


data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_subnet" "subnet" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_name}"]
  }
 }

  data "aws_lb_target_group" "nlb_target_grp" {
    
  count        = "${var.lb_tg_attach == true ? 1 : 0}"
  name = "${var.lb_tg_name}"
}

resource "aws_security_group" "SG-Allow" {
  name        = var.sg_name
  description = "Security Group to allow traffic"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    "Name" =  var.sg_name
  }
}

resource "aws_network_interface" "DataInt" {
  subnet_id       = data.aws_subnet.subnet.id
  security_groups = ["${aws_security_group.SG-Allow.id}"]
  source_dest_check = false
  tags = {
    Name = "${var.instance_name}-${var.subnet_name}"
  }
}


resource "aws_instance" "EC2Instance" {
  ami           = var.ami_id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${var.instance_name}-${var.availability_zone}"
  }

  availability_zone = "${data.aws_region.current.name}${var.availability_zone}"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.DataInt.id
  }
}



resource "aws_eip" "instance-public-ip" {

  count = var.public_ip ? 1 : 0

  instance = aws_instance.EC2Instance.id
  vpc      = true
}

resource "aws_alb_target_group_attachment" "instance_attach_tg" {

  count = var.lb_tg_attach == true ? 1 : 0

  target_group_arn = data.aws_lb_target_group.nlb_target_grp == null ? null : data.aws_lb_target_group.nlb_target_grp[0].arn
  target_id        = tolist(aws_network_interface.DataInt.private_ips)[0]
  port             = 80

}

