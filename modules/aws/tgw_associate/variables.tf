variable "vpc_name" {
  description = "The name of the VPC"
  type = string

}

variable "vpc_type" {

  description = "Type of the VPC (Security=sec or Spoke=spoke)"
  type = string

}

variable "tgw_name" {
  description = "The id of the TGW"
  type = string

}