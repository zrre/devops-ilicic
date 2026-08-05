include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = [
    "../network",
    "../../shared/network",
  ]
}

dependency "test_network" {
  config_path = "../network"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    vnet_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-test-vnet"
  }
}

dependency "shared_network" {
  config_path = "../../shared/network"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    vnet_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-shared-vnet"
  }
}

terraform {
  source = "../../../modules/vnet-peering"
}

inputs = {
  test_resource_group_name = "rg-ilicic-devops-test"
  test_vnet_name           = "vnet-ilicic-devops-test"
  test_vnet_id             = dependency.test_network.outputs.vnet_id

  shared_resource_group_name = "rg-ilicic-devops-shared"
  shared_vnet_name           = "vnet-ilicic-devops-shared"
  shared_vnet_id             = dependency.shared_network.outputs.vnet_id
}
