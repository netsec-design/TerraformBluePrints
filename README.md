# PublicCloudNGFW

This REPO will collect all the Blueprints which Cisco will release as part of the reference architecture designs for Public Cloud.

The structure of the repo is the following where the module folder will store the cloud and cisco building blocks, and the prod in this case represents a "production"environment which as part you can find the design blueprints.

The following blueprints are available:
- Scalable Remote Access VPN with DNS-Loadbalancing utilizing AWS Route 53 Service (preferred/recommended)
- Scalable Remote Access VPN with NLB

The list of modules will constantly grow as long as we will release more and more documentation.


```
├── modules
│   ├── aws
│   │   ├── ec2
│   │   │   └── instance
│   │   ├── nlb
│   │   ├── nlb_enhanced
│   │   ├── r53
│   │   ├── tgw_associate
│   │   ├── tgw_propagate
│   │   └── vpc
│   └── cisco
│       └── asav_enhanced
└── prod
    ├── scalable_ravpn
    │   ├── 0_aws_ssh_key
    │   ├── 1_aws_network
    │   ├── 2_aws_lb_layer
    │   ├── 3_asav_config
    │   ├── 4_asav_deployment
    │   ├── 5_optional_workload
    │   └── variables (the metadata for the resources can be found under main.tfvars file)
    └── scalable_ravpn_r53
        ├── 0_aws_ssh_key
        ├── 1_aws_network
        ├── 2_asav_config
        ├── 3_aws_r53_frontend
        ├── 4_asav_deployment
        └── variables (the metadata for the resources can be found under main.tfvars file)
```



