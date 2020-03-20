variable "vpc_name" {

    type = string
    
}

variable "availability_zone" {

    type = string
    
}

variable "subnet_name" {

    type = string
    
}

variable "instance_size" {

    type = string
    
}

variable "instance_name" {

    type = string
    
}

variable "ami_id" {

    type = string
}

variable "key_name" {

    type = string
}

variable "public_ip" {

    type = bool
}

variable "sg_name" {

    type = string
}

variable "from_port" {

    type = string
}

variable "to_port" {

    type = string
}

variable "protocol" {

    type = string
}

variable "lb_tg_attach" {

    type = bool
    
}
variable "lb_tg_name" {

    type = string
    default = null
    
}