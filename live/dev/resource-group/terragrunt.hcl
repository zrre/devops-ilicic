locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.tfstate_storage_account_name
    container_name       = local.env.locals.tfstate_container_name
    key                  = "dev/resource-group.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/resource-group"
}

inputs = {
  resource_group_name = local.env.locals.workload_resource_group_name
  location            = local.env.locals.location
  tags                = local.env.locals.tags
}
