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
    "../peering-shared",
    "../../shared/private-services",
    "../../shared/dns-links-test",
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
      app = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-app"
    }
  }
}

dependency "private_services" {
  config_path = "../../shared/private-services"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    acr_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.ContainerRegistry/registries/mockacr"
  }
}

terraform {
  source = "../../../modules/aks-private"
}

inputs = {
  resource_group_name      = "rg-ilicic-devops-test"
  location                 = local.env.locals.location
  cluster_name             = "aks-ilicic-devops-test"
  dns_prefix               = "aks-ilicic-devops-test"
  node_resource_group_name = "rg-ilicic-devops-test-aks-nodes"

  system_node_subnet_id = dependency.network.outputs.subnet_ids["app"]
  user_node_subnet_id   = dependency.network.outputs.subnet_ids["aks"]
  acr_id                = dependency.private_services.outputs.acr_id

  node_count   = 1
  node_vm_size = "Standard_D2s_v5"

  user_node_pool_name       = "userpool"
  user_node_pool_vm_size    = "Standard_D2s_v5"
  user_node_pool_node_count = 1
  user_node_pool_max_pods   = 50

  pod_cidr       = "10.244.0.0/16"
  service_cidr   = "10.240.0.0/16"
  dns_service_ip = "10.240.0.10"

  tags = merge(local.env.locals.tags, {
    role = "private-aks"
  })
}