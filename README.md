# PublicCloudNGFW

This REPO will collect all the Blueprints which Cisco will release as part of the reference architecture designs for Public Cloud.

The structure of the repo is the following where the module folder will store the cloud and cisco building blocks, and the prod in this case represents a "production"environment which as part you can find the design blueprints.

The first blueprint is a Scalable Remote Access VPN solution hosted in AWS.

```
├── modules
│   ├── aws
│   │   ├── ec2
│   │   │   └── instance
│   │   ├── nlb
│   │   ├── nlb_enhanced
│   │   ├── tgw_associate
│   │   ├── tgw_propagate
│   │   └── vpc
│   └── cisco
│       └── asav_enhanced
└── prod
    └── scalable_ravpn
        ├── 0_aws_ssh_key
        ├── 1_aws_network
        ├── 2_aws_lb_layer
        ├── 3_asav_config
        ├── 4_asav_deployment
        ├── 5_optional_workload
        └── variables
```


