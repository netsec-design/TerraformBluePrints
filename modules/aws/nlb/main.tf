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
  load_balancer_type = "network"
  subnets            = [data.aws_subnet.subnet_data_a.id, data.aws_subnet.subnet_data_b.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = var.cross_zone

  tags = {
    Name = var.nlb_name
    Environment = "production"
  }
}

resource "aws_lb_target_group" "fw_target_grp" {
  name     = var.target_grp_name
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_vpc.vpc.id
  target_type = "ip"
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn       = aws_lb.nlb.arn
  port                = 80
  protocol            = "TCP"
     
  default_action {
        target_group_arn = aws_lb_target_group.fw_target_grp.arn
        type             = "forward"
      }
}

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn       = aws_lb.load_balancer.arn
#   for_each = var.forwarding_config
#       port                = each.key
#       protocol            = each.value
#       default_action {
#         target_group_arn = "${aws_lb_target_group.tg[each.key].arn}"
#         type             = "forward"
#       }
# }