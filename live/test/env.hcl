locals {
  environment = "test"
  location    = "westeurope"

  backend_resource_group_name  = "rg-ilicic-devops-tfstate"
  backend_storage_account_name = "stilicicdevopstf"
  backend_container_name       = "tfstate"

  tags = {
    owner       = "znebrigic"
    environment = "test"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
}