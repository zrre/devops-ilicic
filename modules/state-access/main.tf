data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.storage_resource_group_name
}

# resource "azurerm_storage_account_network_rules" "this" {
#   storage_account_id = data.azurerm_storage_account.this.id

#   default_action             = "Deny"
#   ip_rules                   = var.allowed_public_ips
#   virtual_network_subnet_ids = var.allowed_subnet_ids

#   bypass = [
#     "AzureServices"
#   ]
# }
