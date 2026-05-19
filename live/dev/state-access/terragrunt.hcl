locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "network" {
  config_path = "../network"
}

dependency "test_vm" {
  config_path = "../test-vm"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.tfstate_storage_account_name
    container_name       = local.env.locals.tfstate_container_name
    key                  = "dev/state-access.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/state-access"
}

inputs = {
  storage_account_name        = local.env.locals.tfstate_storage_account_name
  storage_resource_group_name = local.env.locals.backend_resource_group_name

  allowed_public_ips = local.env.locals.allowed_public_ips

  allowed_subnet_ids = [
    dependency.network.outputs.subnet_ids["app"],
    dependency.network.outputs.subnet_ids["data"],
    dependency.network.outputs.subnet_ids["mgmt"]
  ]
}
