# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "main_cidr" {
  description = "The CIDR list of the whole cloud network (for example: 10.0.0.0/8)"
  default = " "

}

variable "vpc_name" {
  description = "The name of the VPC"

}

variable "vpc_type" {

  description = "Type of the VPC (Security=sec or Spoke=spoke)"
  type = string

}

variable "tgw_attached" {
  description = "TGW attached VPC?"
  type = bool
  default = false
}

variable "tgw_id" {
  description = "TGW_ID"
  type = string
  default = null
}

variable "tgw_attach_id" {
  description = "TGW_ATTACH_ID"
  type = string
  default = null
}

variable "tgw_route_table_id" {
  description = "TGW_ROUTE_TABLE_ID"
  type = string
  default = null
}


variable "vpc_cidr" {
  description = "The CIDR list of the VPC"
  default = null

}

variable "subnet_vpc_id" {
  description = "ID of the VPC"
  default = null
}


variable "networks" {
  type = list(object({
    name    = string
    az = string
    cidr = any
    ntype = string
  }))
}

variable "route_tables" {
  type = list(object({
    name    = string
    rtype   = string
  }))
}

variable "tgw_route_tables" {
  type = list(object({
    name    = string
    type   = string
  }))
  default = null
}

variable "tgw_name" {
  type = string
  default = "Test"
}

variable "tgw_count" {
  type = number
  default = 0
}

variable "igw_name" {
  type = string
  default = "Test"
}

variable "on_prem_cidr" {

  type = string
  default = null
}