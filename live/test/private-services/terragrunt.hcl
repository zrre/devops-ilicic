include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = ["../resource-group"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]

  mock_outputs = {
    vnet_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet"

    subnet_ids = {
      mgmt              = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-mgmt"
      private_endpoints = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-private-endpoints"
    }
  }
}


terraform {
  source = "../../../modules/private-services"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-test"
  location            = local.env.locals.location

  vnet_id                    = dependency.network.outputs.vnet_id
  private_endpoint_subnet_id = dependency.network.outputs.subnet_ids["private_endpoints"]

  acr_name             = "acrilicicdevopstest"
  storage_account_name = "stilicicapptest"
  key_vault_name       = "kv-ilicic-devops-test"

  tags = local.env.locals.tags
}