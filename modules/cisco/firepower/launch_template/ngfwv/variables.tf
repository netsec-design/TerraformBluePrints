variable "ami_owner_id" {

    type = string
    
}

variable "vpc_name" {

    type = string
    
}

variable "availability_zones" {

    type = list(string)
    
}

variable "subnet_mgmt_name" {

    type = string
    
}

variable "subnet_mgmt_name_b" {

    type = string
    
}

variable "subnet_data1_name" {

    type = string
    
}

variable "subnet_data2_name" {

    type = string
    
}

variable "ftd_hostname" {

    type = string
    
}

variable "ftd_password" {

    type = string
    
}

variable "fmc_ip" {

    type = string
    
}

variable "fmc_reg_key" {

    type = string
    
}
variable "fmc_nat_id" {

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


variable "asg_name" {

    type = string
    
}

variable "health_check_type" {

    type = string
    default = "ELB"
    
}

variable "asg_minsize" {

    type = number
    default = 2
    
}

variable "asg_maxsize" {

    type = number
    default = 6
    
}

variable "health_check_grace_period" {

    type = number
    default = 300
    
}