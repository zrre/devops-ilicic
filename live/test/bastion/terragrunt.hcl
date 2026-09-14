include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "network" {
  config_path = "../network"
}

terraform {
  source = "../../../modules/bastion"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-test"
  location            = local.env.locals.location

  public_ip_name = "pip-ilicic-bastion-test"
  bastion_name   = "bas-ilicic-devops-test"

  bastion_subnet_id = dependency.network.outputs.subnet_ids["bastion"]

  tags = local.env.locals.tags
}
