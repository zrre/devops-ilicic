locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../modules/bootstrap"
}

inputs = {
  resource_group_name = local.env.locals.backend_resource_group_name
  location            = local.env.locals.location

  storage_account_name   = local.env.locals.tfstate_storage_account_name
  storage_container_name = local.env.locals.tfstate_container_name

  tags = local.env.locals.tags
}
