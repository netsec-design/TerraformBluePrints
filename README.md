# PublicCloudNGFW

This REPO will collect all the Blueprints which Cisco will release as part of the reference architecture designs for Public Cloud.

The structure of the repo is the following where the module folder will store the cloud and cisco building blocks, and the prod in this case represents a "production"environment which as part you can find the design blueprints.

The following blueprints are available:
- Scalable Remote Access VPN with DNS-Loadbalancing utilizing AWS Route 53 Service (preferred/recommended)
- Scalable Remote Access VPN with NLB

The list of modules will constantly grow as long as we will release more and more documentation.

```
Title: Cisco Firewall Scalable VPN Solution in AWS (PDF) - Reference Architecture Guide
[SalesConnect Link](https://salesconnect.cisco.com/open.html?c=6d4a925e-0970-4263-af9b-d47f00a9066c)
 
Title:  Cisco Firewall Scalable VPN Solution in AWS (PPT) - Short Presentation
[SalesConnect Link](https://salesconnect.cisco.com/open.html?c=42ce8ec2-1c73-4c3c-aacc-bc793751a3b4)

Both links are public material, only need your CCO ID to access to it.
```

```
├── modules (abstract Terraform modules)
│   ├── aws
│   │   ├── ec2
│   │   │   └── instance
│   │   ├── nlb
│   │   ├── nlb_enhanced
│   │   ├── r53
│   │   ├── tgw_associate
│   │   ├── tgw_propagate
│   │   ├── tgw_vpn_attachment
│   │   └── vpc
│   └── cisco
│       └── asav_enhanced
└── prod (Representative environments)
    ├── scalable_ravpn (NLB Implementation)
    │   ├── 0_aws_ssh_key
    │   ├── 1_aws_network
    │   ├── 2_aws_lb_layer
    │   ├── 3_asav_config
    │   ├── 4_asav_deployment
    │   ├── 5_optional_workload
    │   └── variables (metadata can be found in main.tfvars in this folder)
    └── scalable_ravpn_r53 (Route 53 Implementation - Preferred)
        ├── 0_aws_ssh_key
        ├── 1_aws_network
        ├── 2_tgw_associations
        ├── 3_asav_config
        ├── 4_aws_r53_frontend
        ├── 5_asav_deployment
        ├── 6_s2s_vpn
        └── variables (metadata can be found in main.tfvars in this folder)
```



