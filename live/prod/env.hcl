locals {
  environment = "prod"
  location    = "westeurope"

  backend_resource_group_name  = "rg-ilicic-devops-tfstate"
  backend_storage_account_name = "stilicicdevopstf"

  tags = {
    owner       = "znebrigic"
    environment = "prod"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
}
