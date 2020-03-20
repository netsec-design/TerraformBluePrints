provider "aws" {
  region = var.aws-region

}

locals {

#NLB list needs to bee extended if you define new LBs

    nlb_list = [
    var.nlb1-name,
    var.nlb2-name
  ]


#Private CIDR needs to be extended if you define an additional private cidr in a third AZ for example
  vpc_private_subnets = {
      a = var.private-cidr-a,
      b = var.private-cidr-b
  }

#name of ASAvs from config for config file generation
asav_names = flatten([for asa_key, asa in var.asa-instances: [{
    name = asa_key
}]])

#preprocessing interface ids and private ips of the loadbalancers
  nlb1_interface_ids = "${flatten(["${data.aws_network_interfaces.nlb1_interfaces.ids}"])}"
  nlb2_interface_ids = "${flatten(["${data.aws_network_interfaces.nlb2_interfaces.ids}"])}"  
  
  nlb1_ips = "${flatten([data.aws_network_interface.ifs_nlb1.*.private_ips])}"
  nlb2_ips = "${flatten([data.aws_network_interface.ifs_nlb2.*.private_ips])}"

#turn the nlb1/2 into maps which only contains availability-zone and the private ip - so we can get the right private ip while iterating through on the instances 
nlb1_map = {for lb_key, lb in data.aws_network_interface.ifs_nlb1: lb.availability_zone => lb.private_ip}
nlb2_map = {for lb_key, lb in data.aws_network_interface.ifs_nlb2: lb.availability_zone => lb.private_ip}

}

#this part needs to be extended if you would have more than 2 load balancers (in this case I work with an internal and external one)
data "aws_lb" "nlb1" {
    
    name = "${var.nlb1-name}"
}
data "aws_lb" "nlb2" {
    
    name = "${var.nlb2-name}"
}

#querying External NLB interfaces (it has multiple interfaces in each AZ)
data "aws_network_interfaces" "nlb1_interfaces" {
    filter {
        name = "description"
        values = ["ELB net/${var.nlb1-name}/*"]
    }
    filter {
        name = "status"
        values = ["in-use"]
    }
    filter {
        name = "attachment.status"
        values = ["attached"]
    }
}

#querying Internal NLB interfaces (it has multiple interfaces in each AZ)
data "aws_network_interfaces" "nlb2_interfaces" {
    filter {
        name = "description"
        values = ["ELB net/${var.nlb2-name}/*"]
    }
    filter {
        name = "status"
        values = ["in-use"]
    }
    filter {
        name = "attachment.status"
        values = ["attached"]
    }
}

#individual interfaces - iterate through ont the previous list for External LB
data "aws_network_interface" "ifs_nlb1" {
    count = "${length(local.nlb1_interface_ids)}"
    id = "${local.nlb1_interface_ids[count.index]}"

}

#individual interfaces - iterate through ont the previous list for Internal LB
data "aws_network_interface" "ifs_nlb2" {
    count = "${length(local.nlb2_interface_ids)}"
    id = "${local.nlb2_interface_ids[count.index]}"
}

#config file creation
data "template_file" "template" {
for_each = {for asa_key, asa in var.asa-instances: asa_key => asa}

template = "${file("asav_config_template.txt")}"
  vars = {
  hostname = each.key
  private_subnet = replace(lookup(local.vpc_private_subnets,each.value.availability-zone), "//.*/", "")
  external_lb_ip = lookup(local.nlb1_map, "${var.aws-region}${each.value.availability-zone}")
  internal_lb_ip = lookup(local.nlb2_map, "${var.aws-region}${each.value.availability-zone}")
  idtoken = "${lookup(lookup(var.asa-instances, each.key),"token")}"
  license_throughput = var.asa-license-throughput
  vpn_pool_from = "${lookup(lookup(var.asa-instances, each.key),"vpn-pool-from")}"
  vpn_pool_to = "${lookup(lookup(var.asa-instances, each.key),"vpn-pool-to")}"
  vpn_pool_mask =  "${lookup(lookup(var.asa-instances, each.key),"vpn-pool-mask")}"
  vpc_cidr = replace(var.vpc1-cidr, "//.*/", "")
  }
}


#just a null resource which calls terraform outputs to generate the json render of the config files and save them into individual configurations
resource "null_resource" "asa_templates" {

for_each = {for asa_key, asa in var.asa-instances: asa_key => asa}

  provisioner "local-exec" {  

    command = "terraform output -json | jq -r '.render.value.${each.key}' > ${each.key}.txt"
  }

  triggers = {timestamp = timestamp()}

depends_on = [data.template_file.template]

}