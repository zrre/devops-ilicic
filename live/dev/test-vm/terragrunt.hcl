locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "network" {
  config_path = "../network"
}

dependency "private_services" {
  config_path = "../private-services"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = local.env.locals.backend_resource_group_name
    storage_account_name = local.env.locals.tfstate_storage_account_name
    container_name       = local.env.locals.tfstate_container_name
    key                  = "dev/test-vm.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../../modules/test-vm"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = dependency.resource_group.outputs.location

  vm_name              = local.env.locals.test_vm_name
  vm_size              = local.env.locals.test_vm_size
  admin_username       = local.env.locals.test_vm_admin_user
  admin_ssh_public_key = file("~/.ssh/id_ed25519.pub")

  subnet_id = dependency.network.outputs.subnet_ids["mgmt"]

  acr_id             = dependency.private_services.outputs.acr_id
  acr_login_server   = dependency.private_services.outputs.acr_login_server
  storage_account_id = dependency.private_services.outputs.storage_account_id
  key_vault_id       = dependency.private_services.outputs.key_vault_id

  tags = local.env.locals.tags
}