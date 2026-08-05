output "test_to_shared_peering_id" {
  value = azurerm_virtual_network_peering.test_to_shared.id
}

output "shared_to_test_peering_id" {
  value = azurerm_virtual_network_peering.shared_to_test.id
}
