include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = ["../resource-group", "../network"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]

  mock_outputs = {
    subnet_ids = {
      runner = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-runner"
    }
  }
}

terraform {
  source = "../../../modules/github-runner"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-shared"
  location            = local.env.locals.location

  vm_name        = "vm-ilicic-github-runner"
  vm_size        = "Standard_B2s_v2"
  admin_username = "azureuser"

  subnet_id            = dependency.network.outputs.subnet_ids["runner"]
  admin_ssh_public_key = file("~/.ssh/id_ed25519.pub")

  github_repo_url     = "https://github.com/zrre/devops-ilicic"
  github_runner_token = get_env("TF_VAR_github_runner_token", "")

  github_runner_labels = [
    "azure",
    "linux",
    "x64",
    "shared",
  ]

  allowed_ssh_public_ips = [
    "77.46.241.175",
    "79.175.106.38",
    "178.221.121.217",
    "93.86.182.168",
    "109.93.112.233",
  ]

  tags = merge(local.env.locals.tags, {
    role = "github-runner"
  })
}
