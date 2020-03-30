#global 
aws-region = "us-east-1"

# SSH Key Variables
ssh-key-name =  "aws-cloudedge"
ssh-key =  "   " #To be filled out


#VPC Parameters
vpc1-name = "CloudEdge_Terraform"
vpc1-cidr = "100.100.0.0/16"
public-subnet-a = "CloudEdge-Pub-A"
public-subnet-b = "CloudEdge-Pub-B"
private-subnet-a = "CloudEdge-Priv-A"
private-subnet-b = "CloudEdge-Priv-B"
mgmt-subnet-a = "CloudEdge-MGMT-A"
mgmt-subnet-b = "CloudEdge-MGMT-B"
public-cidr-a = "100.100.110.0/24"
public-cidr-b = "100.100.120.0/24"
private-cidr-a = "100.100.11.0/24"
private-cidr-b = "100.100.12.0/24"
mgmt-cidr-a = "100.100.1.0/24"
mgmt-cidr-b = "100.100.2.0/24"
igw-name = "CloudEdge-IGW"
rt1-postfix = "RT1-PUB"
rt2-postfix = "RT2-PRIVA"
rt3-postfix = "RT2-PRIVB"
rt4-postfix = "RT3-MGMT"

#NLB Parameters
#params:
#Name - LB name
#Internal - boolean - to say whether the LB should be internal or external facing
#Cross-Zone - enabled? = Bool to enable cross-zone loadbalancing
#tg-config: target group configuration (multiple target groups are being created based on forwarding configuration this is a dynamic section)
#name inside of tg-config: prefix to create the target group - the final name will look like: ${prefix}+${protocol}+${port} - for example TG01ASAvTCP80
#nlb1-fw-config: forwarding configuration with given amount of ports 


#External Load-balancer definiton 
nlb1-name =  "NLB01External"
nlb1-internal = "false"
nlb1-cross-zone = true
nlb1-tg-config = {
    name = "TG01ASAv"
    target_type = "ip"
    health_check_protocol = "TCP"
}
nlb1-fw-config = {
    80 = "TCP"
    443 = "TCP"
}

#Params for the internal load-balancer are slightly different as for the workloads module does not support my enhanced LB layed module yet.
#Not a big deal, but it's a bit more static config in this case - doesn't have impact on the RAVPN front-end

#NLB2-Params
nlb2-name = "NLB02Internal"
nlb2-internal = "true"
nlb2-tg-group = "TG02WWWInternal"
nlb2-cross-zone = true



#ASAv General Parameters
ami-owner = "679593333241"
asa-ami-id = "asav9-13-1-7-ENA-6836725a-4399-455a-bf58-01255e5213b8-ami-056e4d25f7577b998.4"
asav-instance-size = "c5.xlarge"
asa-tg-name = {
    80 = "TG01ASAvTCP80"
    443 = "TG01ASAvTCP443"
}
asa-license-throughput = "10G"



#ASAv instances - here we need to define the amount of ASAv instances we need to deploy
#params:
#availability-zone - availability-zone where you want the instances to be deployed
#template file - it's the same as the name of the instance - refer to the files generated in step3
#default to private is require because there is only one default route could exist in the route table so if you want terraform to inject default route pointing towards the particular ASAv
#then you need to change this value to true - *Keep in mind that only one instance could be acting as a default gw per availability zone/ per route table* the rest should be false
#vpn-pool-from: Start of VPN pool range
#vpn-pool-to: End of VPN pool range
#vpn-pool-mask: netmask of the VPN pool

asa-instances = {
        ASAv01={
        availability-zone = "a"
        template-file = "../3_asav_config/ASAv01.txt"
        token = " " #To be filled out
        default-to-private = true
        vpn-pool-cidr = "192.168.6.0/24"
        vpn-pool-from = "192.168.6.1"
        vpn-pool-to = "192.168.6.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = false
        weight = null
        },
        ASAv02={
        availability-zone = "b"
        template-file = "../3_asav_config/ASAv02.txt"
        token = " " #to be filled
        default-to-private = true
        vpn-pool-cidr = "192.168.4.0/24"
        vpn-pool-from = "192.168.4.1"
        vpn-pool-to = "192.168.4.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = false
        weight = null
        }/*,
        ASAv03={
        availability-zone = "a"
        template-file = "../3_asav_config/ASAv03.txt"
        token = " " #to be filled
        default-to-private = false
        vpn-pool-cidr = "192.168.5.0/24"
        vpn-pool-from = "192.168.5.1"
        vpn-pool-to = "192.168.5.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = false
        weight = null
        }*/
}


#Workload general parameters
instance-ami-id = "ami-0a887e401f7654935"
ec2-instance-size = "t2.micro"

#Instance1 Jumphost in AZ A
instance01-name = "OOB-Jump-01-A"
instance01-az = "a"
instance01-tg-attach = "false"
instance01-public-ip = "true"
instance01-from-to-port = "22"
instance01-proto = "tcp"
#Instance2 Jumphost in AZ B
instance02-name = "OOB-Jump-02-B"
instance02-az = "b"
instance02-tg-attach = "false"
instance02-public-ip = "true"
instance02-from-to-port = "22"
instance02-proto = "tcp"
#Instance3 WWW host in AZ A
instance03-name = "WWW-01-A"
instance03-az = "a"
instance03-tg-attach = "true"
instance03-public-ip = "false"
instance03-from-to-port = "0"
instance03-proto = "-1"
#Instance4 WWW host in AZ B
instance04-name = "WWW-02-B"
instance04-az = "b"
instance04-tg-attach = "true"
instance04-public-ip = "false"
instance04-from-to-port = "0"
instance04-proto = "-1"
