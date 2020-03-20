provider "aws" {
  region = "us-east-1"
}

#This is an example of creating some internal workloads for being jumpboxes or internal WWW servers
#the workload module needs to be reworked ro support the enhanced LB layer + to handle instance creation with for_each

locals {

  vpc1_name = var.vpc1-name
  ami_id =  var.instance-ami-id
  instance_size = var.ec2-instance-size
  subnet_name_instance01 = var.mgmt-subnet-a
  subnet_name_instance02 = var.mgmt-subnet-b
  subnet_name_instance03 = var.private-subnet-a
  subnet_name_instance04 = var.private-subnet-b
  key_name = var.ssh-key-name
  instance_www_tg_name = var.nlb2-tg-group
  instance01_name = var.instance01-name
  instance02_name = var.instance02-name
  instance03_name = var.instance03-name
  instance04_name = var.instance04-name
  instance01_az = var.instance01-az
  instance02_az = var.instance02-az
  instance03_az = var.instance03-az
  instance04_az = var.instance04-az
  instance01_public_ip = var.instance01-public-ip
  instance01_tg_attach = var.instance01-tg-attach
  instance02_public_ip = var.instance02-public-ip
  instance02_tg_attach = var.instance02-tg-attach
  instance03_public_ip = var.instance03-public-ip
  instance03_tg_attach = var.instance03-tg-attach
  instance04_public_ip = var.instance04-public-ip
  instance04_tg_attach = var.instance04-tg-attach
  instance01_from_to_port = var.instance01-from-to-port
  instance01_proto = var.instance01-proto
  instance02_from_to_port = var.instance02-from-to-port 
  instance02_proto = var.instance02-proto 
  instance03_from_to_port = var.instance03-from-to-port 
  instance03_proto = var.instance03-proto
  instance04_from_to_port = var.instance04-from-to-port 
  instance04_proto = var.instance04-proto

}

module "jumpbox_instance_01" {

source = "../../../modules/aws/ec2/instance"

vpc_name = local.vpc1_name
ami_id = local.ami_id
key_name = local.key_name
availability_zone = local.instance01_az
instance_name = local.instance01_name
instance_size = local.instance_size
subnet_name = local.subnet_name_instance01
sg_name = "EC2-Allow-All-${local.instance01_name}"
public_ip = local.instance01_public_ip
from_port = local.instance01_from_to_port
to_port = local.instance01_from_to_port
protocol = local.instance01_proto
lb_tg_attach = local.instance01_tg_attach

}

module "jumpbox_instance_02" {

source = "../../../modules/aws/ec2/instance"

vpc_name = local.vpc1_name
ami_id = local.ami_id
key_name = local.key_name
availability_zone = local.instance02_az
instance_name = local.instance02_name
instance_size = local.instance_size
subnet_name = local.subnet_name_instance02
sg_name = "EC2-Allow-All-${local.instance02_name}"
public_ip = local.instance02_public_ip
from_port = local.instance02_from_to_port
to_port = local.instance02_from_to_port
protocol = local.instance02_proto
lb_tg_attach = local.instance02_tg_attach

}


module "www_instance_01" {

source = "../../../modules/aws/ec2/instance"

vpc_name = local.vpc1_name
ami_id = local.ami_id
key_name = local.key_name
availability_zone = local.instance03_az
instance_name = local.instance03_name
instance_size = local.instance_size
subnet_name = local.subnet_name_instance03
sg_name = "EC2-Allow-All-${local.instance03_name}"
public_ip = local.instance03_public_ip
from_port = local.instance03_from_to_port
to_port = local.instance03_from_to_port
protocol = local.instance03_proto
lb_tg_attach = local.instance03_tg_attach
lb_tg_name = local.instance_www_tg_name

}


module "www_instance_02" {

source = "../../../modules/aws/ec2/instance"

vpc_name = local.vpc1_name
ami_id = local.ami_id
key_name = local.key_name
availability_zone = local.instance04_az
instance_name = local.instance04_name
instance_size = local.instance_size
subnet_name = local.subnet_name_instance04
sg_name = "EC2-Allow-All-${local.instance04_name}"
public_ip = local.instance04_public_ip
from_port = local.instance04_from_to_port
to_port = local.instance04_from_to_port
protocol = local.instance04_proto
lb_tg_attach = local.instance04_tg_attach
lb_tg_name = local.instance_www_tg_name

}