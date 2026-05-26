locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]

  mock_outputs = {
    subnet_ids = {
      app  = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-app"
      data = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-data"
      mgmt = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-mgmt"
    }
  }
}

dependencies {
  paths = ["../test-vm"]
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.backend_storage_account_name
    container_name       = local.env.locals.backend_container_name
    key                  = "workload/state-access.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../../modules/state-access"
}

inputs = {
  storage_resource_group_name = local.env.locals.backend_resource_group_name
  storage_account_name        = local.env.locals.backend_storage_account_name
  allowed_public_ips          = local.env.locals.allowed_public_ips

  allowed_subnet_ids = [
    dependency.network.outputs.subnet_ids["app"],
    dependency.network.outputs.subnet_ids["data"],
    dependency.network.outputs.subnet_ids["mgmt"]
  ]

  tags = local.env.locals.tags
}