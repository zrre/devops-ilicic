locals {
  environment = "shared"
  location    = "westeurope"

  tags = {
    project     = "ilicic-devops"
    environment = "shared"
    managed_by  = "terragrunt"
    owner       = "znebrigic"
  }
}
