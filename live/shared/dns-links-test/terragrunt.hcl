include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependencies {
  paths = [
    "../private-services",
    "../../test/network",
    "../../test/peering-shared",
  ]
}

dependency "test_network" {
  config_path = "../../test/network"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    vnet_id = "/subscriptions/mock/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock-test-vnet"
  }
}

terraform {
  source = "../../../modules/private-dns-vnet-links"
}

inputs = {
  private_dns_zone_resource_group_name = "rg-ilicic-devops-shared"

  private_dns_zone_names = [
    "privatelink.azurecr.io",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]

  virtual_network_id        = dependency.test_network.outputs.vnet_id
  virtual_network_link_name = "link-vnet-ilicic-devops-test"

  tags = local.env.locals.tags
}
