output "public_ip_id" {
  value = azurerm_public_ip.bastion.id
}

output "public_ip_address" {
  value = azurerm_public_ip.bastion.ip_address
}

output "bastion_id" {
  value = azurerm_bastion_host.this.id
}

output "bastion_dns_name" {
  value = azurerm_bastion_host.this.dns_name
}