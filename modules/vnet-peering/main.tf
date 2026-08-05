resource "azurerm_virtual_network_peering" "test_to_shared" {
  name = "peer-${var.test_vnet_name}-to-${var.shared_vnet_name}"

  resource_group_name       = var.test_resource_group_name
  virtual_network_name      = var.test_vnet_name
  remote_virtual_network_id = var.shared_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "shared_to_test" {
  name = "peer-${var.shared_vnet_name}-to-${var.test_vnet_name}"

  resource_group_name       = var.shared_resource_group_name
  virtual_network_name      = var.shared_vnet_name
  remote_virtual_network_id = var.test_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
