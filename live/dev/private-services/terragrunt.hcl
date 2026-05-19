locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "network" {
  config_path = "../network"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.tfstate_storage_account_name
    container_name       = local.env.locals.tfstate_container_name
    key                  = "dev/private-services.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/private-services"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = dependency.resource_group.outputs.location

  vnet_id                     = dependency.network.outputs.vnet_id
  private_endpoint_subnet_id  = dependency.network.outputs.subnet_ids["mgmt"]

  acr_name             = local.env.locals.acr_name
  storage_account_name = local.env.locals.app_storage_name
  key_vault_name       = local.env.locals.key_vault_name

  tags = local.env.locals.tags
}