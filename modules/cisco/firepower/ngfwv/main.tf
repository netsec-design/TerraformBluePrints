data "aws_region" "current" {}

data "aws_ami" "cisco-ftd-lookup" {
  most_recent = true

  filter {
    name = "name"
    values = ["ftdv*"]
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

 data "aws_subnet" "subnet_data_1" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_data1_name}"]
  }
 }

 data "aws_subnet" "subnet_data_2" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_data2_name}"]
  }
 }


resource "aws_security_group" "SG-Allow-All" {
  name        = "SG-Allow-All-NGFWv"
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
    "Name" = "SG-Allow-All-NGFWv"
  }
}

resource "aws_network_interface" "FTDv-Management" {
  subnet_id       = data.aws_subnet.subnet_mgmt.id
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_mgmt_name}"
  }
}
resource "aws_network_interface" "FTDv-Diagnostic" {
  subnet_id       = data.aws_subnet.subnet_mgmt.id
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_mgmt_name}-diag"
  }
}
resource "aws_network_interface" "FTDv-Outside" {
  subnet_id       = data.aws_subnet.subnet_data_1.id
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_data1_name}-Outside"
  }
}
resource "aws_network_interface" "FTDv-Inside" {
  subnet_id       = data.aws_subnet.subnet_data_2.id
  security_groups = ["${aws_security_group.SG-Allow-All.id}"]
  source_dest_check = false
  tags = {
    "Name" = "${var.instance_name}-${var.subnet_data2_name}-Inside"
  }
}

data "template_file" "FTDv-init" {
  template = "${file("${path.module}/ngfwv_config.txt")}"

  vars = {
    ftd_password = "${var.ftd_password}"
    ftd_hostname = "${var.ftd_hostname}"
    fmc_ip       = "${var.fmc_ip}"
    fmc_reg_key  = "${var.fmc_reg_key}"
    fmc_nat_id   = "${var.fmc_nat_id}"
  }
}

resource "aws_instance" "FTDv" {
  ami           = data.aws_ami.cisco-ftd-lookup.id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${var.instance_name}-${var.availability_zone}"
  }

  availability_zone = "${data.aws_region.current.name}${var.availability_zone}"

  user_data = data.template_file.FTDv-init.rendered

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.FTDv-Management.id
  }

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.FTDv-Diagnostic.id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.FTDv-Outside.id
  }

  network_interface {
    device_index = 3
    network_interface_id = aws_network_interface.FTDv-Inside.id
  }
}
