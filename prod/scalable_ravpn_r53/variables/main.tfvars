#global 
aws-region = "us-east-1"

# SSH Key Variables
ssh-key-name =  "aws-cloudedge"
ssh-key =  "" #to be filled out

#VPC Parameters
vpc1-name = "Scalable RAVPN R53"
vpc1-cidr = "10.10.0.0/16"
public-subnet-a = "RAVPN-Pub-A"
public-subnet-b = "RAVPN-Pub-B"
private-subnet-a = "RAVPN-Priv-A"
private-subnet-b = "RAVPN-Priv-B"
mgmt-subnet-a = "RAVPN-MGMT-A"
mgmt-subnet-b = "RAVPN-MGMT-B"
public-cidr-a = "10.10.110.0/24"
public-cidr-b = "10.10.120.0/24"
private-cidr-a = "10.10.11.0/24"
private-cidr-b = "10.10.12.0/24"
mgmt-cidr-a = "10.10.1.0/24"
mgmt-cidr-b = "10.10.2.0/24"
igw-name = "RAVPN-IGW"
rt1-postfix = "RAVPN-RT1-PUB"
rt2-postfix = "RAVPN-RT2-PRIVA"
rt3-postfix = "RAVPN-RT2-PRIVB"
rt4-postfix = "RAVPN-RT3-MGMT"


#R53 Parameters

dns-name = " " #example domain you own
vpn-sub-domain = "vpn" #prefix for the sub-domain of the VPN front-end
r53-health-check-port = "443" #same port as your Anyconnect service is running

#ASAv General Parameters
ami-owner = "679593333241" #AWS AMI owner
asa-ami-id = "asav9-13-1-7-ENA-6836725a-4399-455a-bf58-01255e5213b8-ami-056e4d25f7577b998.4" #AWS AMI id
asav-instance-size = "c5.xlarge"
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
#attach-to-dns - if the instance should take a apart in the Load-balancing
#weight - how much percentage of the traffic should be routed towards the instance 

asa-instances = {
        RAVPNASAv01={
        availability-zone = "a"
        template-file = "../2_asav_config/RAVPNASAv01.txt"
        token = " " #example
        default-to-private = true
        vpn-pool-from = "192.168.1.1"
        vpn-pool-to = "192.168.1.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = true
        weight = 10
        },
        RAVPNASAv02={
        availability-zone = "b"
        template-file = "../2_asav_config/RAVPNASAv02.txt"
        token = " "  #example
        default-to-private = true
        vpn-pool-from = "192.168.2.1"
        vpn-pool-to = "192.168.2.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = true
        weight = 10
        },
        RAVPNASAv03={
        availability-zone = "b"
        template-file = "../2_asav_config/RAVPNASAv03.txt"
        token = " "  #example
        default-to-private = false
        vpn-pool-from = "192.168.3.1"
        vpn-pool-to = "192.168.3.254"
        vpn-pool-mask = "255.255.255.0"
        attach-to-dns = true
        weight = 5
        }
        
}
