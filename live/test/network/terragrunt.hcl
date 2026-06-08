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
  resource_group_name = "rg-ilicic-devops-test"
  location            = local.env.locals.location

  vnet_name     = "vnet-ilicic-devops-test"
  address_space = ["10.10.0.0/16"]

  subnets = {
    app = {
      name              = "snet-app-test"
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    data = {
      name              = "snet-data-test"
      address_prefixes  = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    mgmt = {
      name              = "snet-mgmt-test"
      address_prefixes  = ["10.10.3.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    private_endpoints = {
      name              = "snet-private-endpoints-test"
      address_prefixes  = ["10.10.4.0/24"]
      service_endpoints = []
    }

    aks = {
      name              = "snet-aks-test"
      address_prefixes  = ["10.10.10.0/23"]
      service_endpoints = []
    }
  }

  nsg_rules = {
    app = [
      {
        name                       = "allow-agw-https-to-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.10.100.0/24"
        destination_address_prefix = "10.10.1.0/24"
      },
      {
        name                       = "deny-internet-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    ]

    data = [
      {
        name                       = "allow-app-to-db"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.10.2.0/24"
      },
      {
        name                       = "deny-internet-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    ]

    mgmt = [
      {
        name                   = "allow-ssh-from-public-ips"
        priority               = 100
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        source_port_range      = "*"
        destination_port_range = "22"
        source_address_prefixes = [
          "77.46.241.175",
          "79.175.106.38",
          "178.221.121.217"
        ]
        destination_address_prefix = "10.10.3.0/24"
      },
      {
        name                       = "deny-internet-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    ]

    private_endpoints = []
    aks               = []
  }

  tags = local.env.locals.tags
}
