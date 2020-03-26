variable "ami_owner_id" {

    type = string
    
}

variable "asa_ami_id" {

    type = string
    
}

variable "vpc_name" {

    type = string
    
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