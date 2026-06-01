output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "principal_id" {
  value = azurerm_linux_virtual_machine.this.identity[0].principal_id
}
