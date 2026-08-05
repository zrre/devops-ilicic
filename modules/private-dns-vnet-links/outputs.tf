output "private_dns_vnet_link_ids" {
  value = {
    for zone_name, link in azurerm_private_dns_zone_virtual_network_link.this :
    zone_name => link.id
  }
}
