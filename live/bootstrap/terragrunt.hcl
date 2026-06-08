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
    "93.86.182.168"
  ]

  tags = {
    owner       = "znebrigic"
    environment = "shared"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
}
