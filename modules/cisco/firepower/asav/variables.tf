variable "ami_owner_id" {

    type = string
    
}

variable "vpc_name" {

    type = string
    
}

variable "availability_zone" {

    type = string
    
}

variable "subnet_mgmt_name" {

    type = string
    
}


variable "subnet_outside_name" {

    type = string
    
}

variable "subnet_inside_name" {

    type = string
    
}

variable "instance_size" {

    type = string
    
}

variable "instance_name" {

    type = string
    
}

variable "key_name" {

    type = string
    
}

variable "lb_tg_name" {

    type = map

}

variable "lb_tg_attach" {

    type = bool
    
}

variable "public_ip" {

    type = bool
    
}

variable "template_file" {

    type = string
    
}