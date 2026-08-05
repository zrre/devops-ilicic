resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = toset(var.private_dns_zone_names)

  name                  = var.virtual_network_link_name
  resource_group_name   = var.private_dns_zone_resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = var.virtual_network_id

  registration_enabled = false

  tags = var.tags
}
