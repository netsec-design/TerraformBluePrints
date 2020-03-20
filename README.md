# PublicCloudNGFW

This REPO will collect all the Blueprints which Cisco will release as part of the reference architecture designs for Public Cloud.

The structure of the repo is the following:

```
├── README.md
├── modules
│   ├── aws
│   │   ├── ec2
│   │   │   └── instance
│   │   │       ├── main.tf
│   │   │       ├── output.tf
│   │   │       └── variables.tf
│   │   ├── nlb
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   ├── nlb_enhanced
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   ├── tgw_associate
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── tgw_propagate
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   └── vpc
│   │       ├── main.tf
│   │       ├── output.tf
│   │       └── variables.tf
│   └── cisco
│       └── asav_enhanced
│           ├── asav_config.txt
│           ├── main.tf
│           ├── output.tf
│           └── variables.tf
└── prod
    └── scalable_ravpn
        ├── 0_aws_ssh_key
        │   ├── deploy.sh
        │   ├── destroy.sh
        │   ├── main.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        ├── 1_aws_network
        │   ├── deploy.sh
        │   ├── destroy.sh
        │   ├── main.tf
        │   ├── output.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        ├── 2_aws_lb_layer
        │   ├── deploy.sh
        │   ├── destroy.sh
        │   ├── main.tf
        │   ├── output.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        ├── 3_asav_config
        │   ├── asav_config_template.txt
        │   ├── asav_config_template_C4.txt
        │   ├── deploy.sh
        │   ├── destroy.sh
        │   ├── main.tf
        │   ├── output.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        ├── 4_asav_deployment
        │   ├── deploy.sh
        │   ├── destroy.sh
        │   ├── main.tf
        │   ├── output.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        ├── 5_optional_workload
        │   ├── main.tf
        │   ├── output.tf
        │   ├── terraform.tfstate
        │   ├── terraform.tfstate.backup
        │   └── variables.tf
        └── variables
            └── main.tfvars
```
