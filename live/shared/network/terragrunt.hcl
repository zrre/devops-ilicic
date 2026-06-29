include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = ["../resource-group"]
}

terraform {
  source = "../../../modules/network"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-shared"
  location            = local.env.locals.location

  vnet_name     = "vnet-ilicic-devops-shared"
  address_space = ["10.20.0.0/16"]

  subnets = {
    runner = {
      name                              = "snet-runner-shared"
      address_prefixes                  = ["10.20.1.0/24"]
      service_endpoints                 = ["Microsoft.Storage"]
      private_endpoint_network_policies = "Enabled"
    }

    private_endpoints = {
      name                              = "snet-private-endpoints-shared"
      address_prefixes                  = ["10.20.2.0/24"]
      service_endpoints                 = []
      private_endpoint_network_policies = "Disabled"
    }
  }

  nsg_rules = {
    runner = [
      {
        name                       = "AllowSSHFromInternet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]

    private_endpoints = []
  }

  tags = local.env.locals.tags
}
