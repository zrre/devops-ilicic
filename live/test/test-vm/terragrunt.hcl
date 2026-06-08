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
    subnet_ids = {
      mgmt = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-mgmt"
    }
  }
}

dependency "private_services" {
  config_path = "../private-services"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]

  mock_outputs = {
    acr_id             = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.ContainerRegistry/registries/mockacr"
    acr_login_server   = "mockacr.azurecr.io"
    storage_account_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Storage/storageAccounts/mockstorage"
    key_vault_id       = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.KeyVault/vaults/mockkv"
  }
}


terraform {
  source = "../../../modules/test-vm"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-test"
  location            = local.env.locals.location

  vm_name              = "vm-ilicic-test-test"
  vm_size              = "Standard_B2s_v2"
  admin_username       = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_ed25519.pub")

  subnet_id            = dependency.network.outputs.subnet_ids["mgmt"]

  acr_id             = dependency.private_services.outputs.acr_id
  acr_login_server   = dependency.private_services.outputs.acr_login_server
  storage_account_id = dependency.private_services.outputs.storage_account_id
  key_vault_id       = dependency.private_services.outputs.key_vault_id

  tags = local.env.locals.tags
}