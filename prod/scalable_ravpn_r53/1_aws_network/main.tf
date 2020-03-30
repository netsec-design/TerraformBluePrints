provider "aws" {
  region = var.aws-region

}

locals {

#don't modify these
nrtypepub       = "pub"
nrtypepriv      = "priv_tgw"
nrtypemgmt      = "mgmt"
nrtypetgw       = "tgw"
tgw_count       = 1
tgw_attached    = true
az_a            = "a"
az_b            = "b"
#important for tgw (could be sec or spoke)
vpc1_type       = var.vpc1-type
}

module "vpc1" {

source = "../../../modules/aws/vpc"

vpc_name = var.vpc1-name
vpc_cidr = var.vpc1-cidr
main_cidr = var.main-cidr
vpc_type = local.vpc1_type
tgw_count = local.tgw_count
tgw_attached = local.tgw_attached
igw_name = var.igw-name
tgw_name        = var.tgw-name
subnet_vpc_id = "${module.vpc1.vpc_id}"
on_prem_cidr = var.on-prem-cidr

  networks = [

    {

      name          = var.private-subnet-a
      az            = local.az_a
      cidr          = var.private-cidr-a
      ntype         = local.nrtypepriv
    },
    {

      name          = var.private-subnet-b
      az            = local.az_b
      cidr          = var.private-cidr-b
      ntype         = local.nrtypepriv
    },
    {

      name          = var.public-subnet-a
      az            = local.az_a
      cidr          = var.public-cidr-a
      ntype         = local.nrtypepub
    },
    {

      name          = var.public-subnet-b
      az            = local.az_b
      cidr          = var.public-cidr-b
      ntype         = local.nrtypepub
    },
    {

      name          = var.mgmt-subnet-a 
      az            = local.az_a
      cidr          = var.mgmt-cidr-a
      ntype         = local.nrtypemgmt
    },
    {

      name          = var.mgmt-subnet-b
      az            = local.az_b
      cidr          = var.mgmt-cidr-b
      ntype         = local.nrtypemgmt
    },
    {

      name          = var.tgw-subnet-a
      az            = local.az_a
      cidr          = var.tgw-cidr-a
      ntype         = local.nrtypetgw
    },
    {

      name          = var.tgw-subnet-b
      az            = local.az_b
      cidr          = var.tgw-cidr-b
      ntype         = local.nrtypetgw
    }
  ]

  route_tables = [

    {
      name          = "${var.vpc1-name}-${var.rt1-postfix}"
      rtype         = local.nrtypepub
    },
    {
      name          = "${var.vpc1-name}-${var.rt2-postfix}"
      rtype         = local.nrtypepriv
    },
    {
      name          = "${var.vpc1-name}-${var.rt3-postfix}"
      rtype         = local.nrtypepriv
    },
    {
      name          = "${var.vpc1-name}-${var.rt4-postfix}"
      rtype         = local.nrtypemgmt
    },
    {
      name          = "${var.vpc1-name}-${var.rt5-postfix}"
      rtype         = local.nrtypetgw
    }

  ]

  tgw_route_tables = [

  {
    name = var.tgw-rt1-name
    type = var.tgw-rt1-type
  },
  {
    name = var.tgw-rt2-name
    type = var.tgw-rt2-type
  }

]


}