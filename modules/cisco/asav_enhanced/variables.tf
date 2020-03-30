variable "ami_owner_id" {

    type = string
    
}

variable "asa_ami_id" {

    type = string
    
}

variable "vpc_name" {

    type = string
    
}

variable "unique_vpn_pools" {

    type = bool
    default = false
}

variable "subnet_mgmt_name" {

    type = map
    
}


variable "subnet_outside_name" {

    type = map
    
}

variable "subnet_inside_name" {

    type = map
    
}

variable "subnet_tgw_name" {

    type = map
    default = null
}

variable "instance_size" {

    type = string
    
}

variable "key_name" {

    type = string
    
}

variable "lb_tg_name" {

    type = map
    default = {}

}

variable "asa_instances" {
  type = map(object({
    availability-zone    = string
    template-file = string
    token = string
    default-to-private = bool
    attach-to-dns = bool
    weight = number
    vpn-pool-cidr = string
  }))
}

variable "dns_name" {

    type = string
    default = null
}

variable "vpn_subdomain" {

    type = string
    default = null

}

variable "r53_health_check_port" {

    type = string
    default = null

}

variable "tgw_name" {

    type = string
    default = null
}

variable "rt_name" {

    type = string
    default = null

}