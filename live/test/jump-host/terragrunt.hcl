include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = [
    "../resource-group",
    "../network",
    "../aks",
  ]
}

dependency "network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    subnet_ids = {
      mgmt = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-mgmt"
    }
  }
}

dependency "aks" {
  config_path = "../aks"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    cluster_id   = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.ContainerService/managedClusters/mock-aks"
    cluster_name = "mock-aks"
    private_fqdn = "mock-aks.privatelink.westeurope.azmk8s.io"
  }
}

terraform {
  source = "../../../modules/aks-jump-host"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-test"
  location            = local.env.locals.location

  vm_name        = "vm-ilicic-aks-jumphost-test"
  vm_size        = "Standard_B2s_v2"
  admin_username = "azureuser"

  admin_ssh_public_key = get_env("ADMIN_SSH_PUBLIC_KEY")
  subnet_id            = dependency.network.outputs.subnet_ids["mgmt"]

  subscription_id         = get_env("ARM_SUBSCRIPTION_ID")
  aks_cluster_id          = dependency.aks.outputs.cluster_id
  aks_cluster_name        = dependency.aks.outputs.cluster_name
  aks_resource_group_name = "rg-ilicic-devops-test"
  aks_private_fqdn        = dependency.aks.outputs.private_fqdn

  tags = merge(local.env.locals.tags, {
    role = "aks-jump-host"
  })
}
