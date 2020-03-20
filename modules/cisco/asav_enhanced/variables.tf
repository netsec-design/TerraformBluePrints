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

}

variable "asa_instances" {
  type = map(object({
    availability-zone    = string
    template-file = string
    token = string
    default-to-private = bool
  }))
}