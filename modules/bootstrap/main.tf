resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  tags = var.tags
}

resource "azurerm_storage_account_network_rules" "tfstate" {
  storage_account_id = azurerm_storage_account.tfstate.id

  default_action = "Deny"
  bypass         = ["AzureServices"]

  ip_rules = var.allowed_public_ips
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_management_lock" "tfstate_rg" {
  name       = "lock-tfstate-rg-delete-protection"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Protect Terraform state resource group from accidental deletion."
}