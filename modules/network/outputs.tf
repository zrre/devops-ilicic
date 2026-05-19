output "resource_group_name" {
  value = var.resource_group_name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = {
    for key, subnet in azurerm_subnet.this :
    key => subnet.id
  }
}

output "nsg_ids" {
  value = {
    for key, nsg in azurerm_network_security_group.this :
    key => nsg.id
  }
}
