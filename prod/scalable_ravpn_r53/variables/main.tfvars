#global 
aws-region = "us-east-1"

# SSH Key Variables
ssh-key-name =  "aws-cloudedge" #To be filled out
ssh-key =  "   " #To be filled out

#VPC Parameters
main-cidr = "10.0.0.0/8" #required for transit-gw (in case if there are multiple vpcs the main /8 subnet will be routed through TGW)
vpc1-name = "Scalable RAVPN R53"
vpc1-cidr = "10.10.0.0/16"
vpc1-type = "sec"
public-subnet-a = "RAVPN-Pub-A"
public-subnet-b = "RAVPN-Pub-B"
private-subnet-a = "RAVPN-Priv-A"
private-subnet-b = "RAVPN-Priv-B"
mgmt-subnet-a = "RAVPN-MGMT-A"
mgmt-subnet-b = "RAVPN-MGMT-B"
tgw-subnet-a = "RAVPN-TGW-A"
tgw-subnet-b = "RAVPN-TGW-B"
public-cidr-a = "10.10.110.0/24"
public-cidr-b = "10.10.120.0/24"
private-cidr-a = "10.10.11.0/24"
private-cidr-b = "10.10.12.0/24"
mgmt-cidr-a = "10.10.1.0/24"
mgmt-cidr-b = "10.10.2.0/24"
tgw-cidr-a = "10.10.111.0/24"
tgw-cidr-b = "10.10.222.0/24"
igw-name = "RAVPN-IGW"
rt1-postfix = "RAVPN-RT1-PUB"
rt2-postfix = "RAVPN-RT2-PRIVA"
rt3-postfix = "RAVPN-RT2-PRIVB"
rt4-postfix = "RAVPN-RT3-MGMT"
rt5-postfix = "RAVPN-RT4-TGW"

#TGW Parameters
tgw-name = "RAVPN-TGW"
tgw-rt1-name = "RAVPN-TGW-Security"
tgw-rt1-type = "sec"
tgw-rt2-name = "RAVPN-TGW-Spoke"
tgw-rt2-type = "spoke"

#S2SVPN Parameters
s2s-gw-name = "Home GW"
s2svpn-bgp-asn = 65534
s2svpn-endpoint-ip = "A.B.C.D" #To be filled out


#ON-Prem CIDR
on-prem-cidr = "192.168.128.0/24" #To be changed to your on-prem network
on-prem-pool = "192.168.128.0"#To be changed to your on-prem network
on-prem-netmask = "255.255.255.0"#To be changed to your on-prem network

#R53 Parameters
dns-name = "example.com" #To be changed to your domain
vpn-sub-domain = "vpn" #To be changed to your example sub-domain (example: vpn means it will be vpn.example.com)
r53-health-check-port = "443" #ASAv Anyconnect service port

#ASAv General Parameters
ami-owner = "679593333241"
asa-ami-id = "asav9-13-1-7-ENA-6836725a-4399-455a-bf58-01255e5213b8-ami-056e4d25f7577b998.4"
asav-instance-size = "c5.xlarge"
asa-license-throughput = "10G"
asa-unique-vpn-pools = true #It is required if you want to implement the "ghost pool" solution described in the reference architecture


#ASAv instances - here we need to define the amount of ASAv instances we need to deploy
#params:
#availability-zone - availability-zone where you want the instances to be deployed
#template file - it's the same as the name of the instance - refer to the files generated in step3
#default to private is require because there is only one default route could exist in the route table so if you want terraform to inject default route pointing towards the particular ASAv
#then you need to change this value to true - *Keep in mind that only one instance could be acting as a default gw per availability zone/ per route table* the rest should be false
#vpn-pool-from: Start of VPN pool range
#vpn-pool-to: End of VPN pool range
#vpn-pool-mask: netmask of the VPN pool
#vpn-pool-cidr: VPN pool in CIDR formar

asa-instances = {
        RAVPNASAv01={
        availability-zone = "a"
        template-file = "../3_asav_config/RAVPNASAv01.txt"
        token = " " #to be filled
        default-to-private = true
        attach-to-dns = true
        weight = 10
        vpn-pool-cidr = "172.16.1.0/24"
        vpn-pool-from = "172.16.1.1"
        vpn-pool-to = "172.16.1.254"
        vpn-pool-mask = "255.255.255.0"
        },
        RAVPNASAv02={
        availability-zone = "b"
        template-file = "../3_asav_config/RAVPNASAv02.txt"
        token = " " #to be filled
        default-to-private = true
        attach-to-dns = true
        weight = 10
        vpn-pool-cidr = "172.16.2.0/24"
        vpn-pool-from = "172.16.2.1"
        vpn-pool-to = "172.16.2.254"
        vpn-pool-mask = "255.255.255.0"
        },
        RAVPNASAv03={
        availability-zone = "b"
        template-file = "../3_asav_config/RAVPNASAv03.txt"
        token = " " #to be filled
        default-to-private = false
        attach-to-dns = true
        weight = 5
        vpn-pool-cidr = "172.16.3.0/24"
        vpn-pool-from = "172.16.3.1"
        vpn-pool-to = "172.16.3.254"
        vpn-pool-mask = "255.255.255.0"
        }/*,
        RAVPNASAv04={
        availability-zone = "a"
        template-file = "../3_asav_config/RAVPNASAv04.txt"
        token = " " #to be filled
        default-to-private = false
        attach-to-dns = true
        weight = 5
        vpn-pool-cidr = "172.16.4.0/24"
        vpn-pool-from = "172.16.4.1"
        vpn-pool-to = "172.16.4.254"
        vpn-pool-mask = "255.255.255.0"
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
