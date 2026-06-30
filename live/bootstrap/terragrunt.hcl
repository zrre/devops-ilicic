terraform {
  source = "../../modules/bootstrap"
}

inputs = {
  resource_group_name    = "rg-ilicic-devops-tfstate"
  location               = "westeurope"
  storage_account_name   = "stilicicdevopstf"
  storage_container_name = "tfstate"

  allowed_public_ips = [
    "77.46.241.175",
    "79.175.106.38",
    "178.221.121.217",
    "93.86.182.168",
    "109.93.112.233",
    "20.229.81.156",
  ]

  allowed_virtual_network_subnet_ids = [
    "/subscriptions/d960facb-8e1a-44d3-be23-1c460b7077ee/resourceGroups/rg-ilicic-devops-shared/providers/Microsoft.Network/virtualNetworks/vnet-ilicic-devops-shared/subnets/snet-runner-shared",
  ]

  tags = {
    owner       = "znebrigic"
    environment = "shared"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
}
