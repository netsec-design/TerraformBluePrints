variable "vpc_name" {
  description = "The name of the VPC which should propagate routes into the TGW RT"
  type = string

}

variable "rt_name" {

  description = "Type of the name of the route table (Security=sec or Spoke=spoke) where you want to propagate"
  type = string

}

variable "tgw_name" {
  description = "The id of the TGW"
  type = string

}