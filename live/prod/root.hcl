locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name  = "rg-ilicic-devops-tfstate"
    storage_account_name = "stilicicdevopstf"
    container_name       = "tfstate"

    key = "${local.env.locals.environment}/${path_relative_to_include()}.tfstate"

    use_azuread_auth = true
  }
}