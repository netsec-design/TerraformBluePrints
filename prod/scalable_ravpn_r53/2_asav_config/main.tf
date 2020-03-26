provider "aws" {
  region = var.aws-region
}

locals {

#name of ASAvs from config for config file generation
asav_names = flatten([for asa_key, asa in var.asa-instances: [{
    name = asa_key
}]])

}

#config file creation
data "template_file" "template" {
for_each = {for asa_key, asa in var.asa-instances: asa_key => asa}

template = "${file("asav_config_template.txt")}"
  vars = {
  hostname = each.key
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