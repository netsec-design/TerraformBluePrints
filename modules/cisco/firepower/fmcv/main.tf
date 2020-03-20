data "aws_region" "current" {}


data "aws_ami" "cisco-fmc-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["fmcv*"]
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

resource "aws_security_group" "SG-Allow-All" {
  name        = "SG-Allow-All-FMCv"
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
    "Name" = "SG-Allow-All-FMCv"
  }
}

resource "aws_network_interface" "FMCv-Management" {
  subnet_id       = data.aws_subnet.subnet_mgmt.id
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  tags = {
    Name = "${var.instance_name}-${var.subnet_mgmt_name}"
  }
}


data "template_file" "FMCv-init" {
  template = "${file("${path.module}/fmcv_config.txt")}"

  vars = {
    fmc_password = "${var.fmc_password}"
    fmc_hostname = "${var.fmc_hostname}"
  }
}

resource "aws_instance" "FMCv" {
  ami           = data.aws_ami.cisco-fmc-lookup.id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${var.instance_name}-${var.availability_zone}"
  }

  availability_zone = "${data.aws_region.current.name}${var.availability_zone}"

  user_data = data.template_file.FMCv-init.rendered

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.FMCv-Management.id
  }
}
