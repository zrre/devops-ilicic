resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                              = each.value.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = each.value.address_prefixes
  service_endpoints                 = each.value.service_endpoints
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

locals {
  nsg_rules_flat = flatten([
    for subnet_key, rules in var.nsg_rules : [
      for rule in rules : {
        subnet_key                   = subnet_key
        name                         = rule.name
        priority                     = rule.priority
        direction                    = rule.direction
        access                       = rule.access
        protocol                     = rule.protocol
        source_port_range            = rule.source_port_range
        destination_port_range       = rule.destination_port_range
        source_address_prefix        = try(rule.source_address_prefix, null)
        source_address_prefixes      = try(rule.source_address_prefixes, null)
        destination_address_prefix   = try(rule.destination_address_prefix, null)
        destination_address_prefixes = try(rule.destination_address_prefixes, null)
      }
    ]
  ])
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for rule in local.nsg_rules_flat :
    "${rule.subnet_key}-${rule.name}" => rule
  }

  name                   = each.value.name
  priority               = each.value.priority
  direction              = each.value.direction
  access                 = each.value.access
  protocol               = each.value.protocol
  source_port_range      = each.value.source_port_range
  destination_port_range = each.value.destination_port_range

  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_key].name
}
