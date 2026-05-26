locals {
  environment = "dev"
  location    = "westeurope"

  acr_name             = "acrilicicdevopsdev"
  app_storage_name     = "stilicicappdevopsdev"
  key_vault_name       = "kv-ilicic-devops-dev"

  test_vm_name         = "vm-ilicic-test-dev"
  test_vm_admin_user   = "azureuser"
  test_vm_size         = "Standard_B2s_v2"

  backend_resource_group_name  = "rg-ilicic-devops-tfstate-dev"
  workload_resource_group_name = "rg-ilicic-devops-dev"

  backend_storage_account_name = "stilicicdevopstfdev"
  backend_container_name       = "tfstate"

  allowed_public_ips = [
    "77.46.241.175",
    "79.175.106.38",
    "178.221.121.217"
  ]
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

    private_endpoints = {
      name              = "snet-private-endpoints-dev"
      address_prefixes  = ["10.10.4.0/24"]
      service_endpoints = []
    }

    aks = {
      name              = "snet-aks-dev"
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
        name                       = "allow-ssh-from-public-ips"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = local.allowed_public_ips
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

    aks = []
  }

  tags = {
    owner       = "znebrigic"
    environment = "dev"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
 
}

