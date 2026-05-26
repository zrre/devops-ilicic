locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = ["../resource-group"]
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.backend_storage_account_name
    container_name       = local.env.locals.backend_container_name
    key                  = "workload/network.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../../modules/network"
}

inputs = {
  resource_group_name = local.env.locals.workload_resource_group_name
  location            = local.env.locals.location

  vnet_name     = local.env.locals.vnet_name
  address_space = local.env.locals.address_space
  subnets       = local.env.locals.subnets
  nsg_rules     = local.env.locals.nsg_rules

  tags = local.env.locals.tags
}
