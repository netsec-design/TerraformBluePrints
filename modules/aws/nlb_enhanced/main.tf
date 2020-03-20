data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }

  depends_on = [data.aws_vpc.vpc]
}

 data "aws_subnet" "subnet_data_a" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_a_name}"]
  }

  depends_on = [data.aws_vpc.vpc]

 }

 data "aws_subnet" "subnet_data_b" {
  
  filter{   
   name = "tag:Name"
   values = ["${var.subnet_b_name}"]
  }

  depends_on = [data.aws_vpc.vpc]
 }


resource "aws_lb" "nlb" {
  name               = var.nlb_name
  internal           = var.internal
  subnets            = [data.aws_subnet.subnet_data_a.id, data.aws_subnet.subnet_data_b.id]
  load_balancer_type = "network"
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = var.cross_zone
  ip_address_type     = "ipv4"

  tags = {
    Name = var.nlb_name
    Environment = "production"
  }
}

resource "aws_lb_target_group" "fw_target_grp_enhanced" {
  for_each = var.forwarding_config
     name                  = "${lookup(var.tg_config, "name")}${replace(each.value, "_", "")}${each.key}"
     port                  = each.key
     protocol              = each.value
     vpc_id                  = data.aws_vpc.vpc.id
     target_type             = lookup(var.tg_config, "target_type")
     deregistration_delay    = 90
    health_check {
        interval            = 10
        port                = each.value != "TCP_UDP" ? each.key : 80
        protocol            = "TCP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
    }
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "listener" {
  for_each = var.forwarding_config
      load_balancer_arn       = aws_lb.nlb.arn
      port                    = each.key
      protocol                = each.value
      default_action {
        target_group_arn = aws_lb_target_group.fw_target_grp_enhanced[each.key].arn
        type             = "forward"
      }
}