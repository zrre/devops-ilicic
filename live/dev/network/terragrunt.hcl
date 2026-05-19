locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "resource_group" {
  config_path = "../resource-group"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.tfstate_storage_account_name
    container_name       = local.env.locals.tfstate_container_name
    key                  = "dev/network.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/network"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = dependency.resource_group.outputs.location

  vnet_name     = "vnet-ilicic-devops-dev"
  address_space = ["10.10.0.0/16"]

  subnets = {
    app = {
      name              = "snet-app-dev"
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    data = {
      name              = "snet-data-dev"
      address_prefixes  = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }

    mgmt = {
      name              = "snet-mgmt-dev"
      address_prefixes  = ["10.10.3.0/24"]
      service_endpoints = ["Microsoft.Storage"]
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
        name                       = "allow-ssh-from-public-ips"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes = local.env.locals.allowed_public_ips
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
  }

  tags = local.env.locals.tags
}
