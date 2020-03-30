provider "aws" {
  region = var.aws-region

}

locals {

#don't modify these
nrtypepub       = "pub"
nrtypepriv      = "priv"
nrtypemgmt      = "mgmt"
tgw_count       = 0
az_a            = "a"
az_b            = "b"
#important for tgw (could be sec or spoke)
vpc1_type       = "single"
}

module "vpc1" {

source = "../../../modules/aws/vpc"

vpc_name = var.vpc1-name
vpc_cidr = var.vpc1-cidr
vpc_type = local.vpc1_type
tgw_count = local.tgw_count
igw_name = var.igw-name
subnet_vpc_id = "${module.vpc1.vpc_id}"


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
    }

  ]


}