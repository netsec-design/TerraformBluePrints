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

 data "aws_subnet" "subnet_mgmt_b" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_mgmt_name_b}"]
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
  name        = "SG-Allow-All-NGFWv-Template"
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

data "template_file" "NGFWv-init" {
  template = "${file("${path.module}/ngfwv_config.txt")}"

  vars = {
    ftd_password = "${var.ftd_password}"
    ftd_hostname = "${var.ftd_hostname}"
    fmc_ip       = "${var.fmc_ip}"
    fmc_reg_key  = "${var.fmc_reg_key}"
    fmc_nat_id   = "${var.fmc_nat_id}"
  }
}

resource "aws_launch_template" "NGFWv_template" {
  name_prefix = "${var.vpc_name}-NGFWv-"
  image_id           = data.aws_ami.cisco-ftd-lookup.id
  instance_type = var.instance_size
  key_name = var.key_name
  tags          = {
    Name = "${var.vpc_name}-${var.instance_name}"
  }

  user_data = base64encode(data.template_file.NGFWv-init.rendered)

  network_interfaces {
    device_index = 0
    subnet_id = data.aws_subnet.subnet_mgmt.id
  }

}


resource "aws_autoscaling_group" "NGFWv_Autoscale_group" {
  availability_zones        = var.availability_zones
  vpc_zone_identifier       = [data.aws_subnet.subnet_mgmt.id, data.aws_subnet.subnet_mgmt_b.id]
  name                      = var.asg_name
  max_size                  = var.asg_maxsize
  min_size                  = var.asg_minsize
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  default_cooldown          = 1320
  force_delete              = true
  launch_template {
    id      = aws_launch_template.NGFWv_template.id
    version = "$Latest"
  }

}

resource "aws_autoscaling_policy" "NGFWv_AutoScale_Policy" {
  name               = "ngfwv-cpu-auto-scaling"
  adjustment_type        = "ChangeInCapacity"
  policy_type        = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.NGFWv_Autoscale_group.name
  estimated_instance_warmup = 1320

  target_tracking_configuration {
    
    customized_metric_specification {
        metric_dimension {
          name = "NGFWv_Autoscale_group"
          value = aws_autoscaling_group.NGFWv_Autoscale_group.name
        }
        metric_name  = "CPUUtilization"
        namespace = "AWS/EC2"
        statistic = "Average"
    }

    target_value       = 75
  }
}


