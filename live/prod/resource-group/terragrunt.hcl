include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}


terraform {
  source = "../../../modules/resource-group"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-prod"
  location            = local.env.locals.location
  tags                = local.env.locals.tags
}
