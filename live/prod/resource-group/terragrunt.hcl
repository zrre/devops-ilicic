locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.backend_storage_account_name
    container_name       = local.env.locals.backend_container_name
    key                  = "prod/resource-group.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/resource-group"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-prod"
  location            = local.env.locals.location
  tags                = local.env.locals.tags
}
