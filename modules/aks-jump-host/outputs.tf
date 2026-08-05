output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "principal_id" {
  value = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}
