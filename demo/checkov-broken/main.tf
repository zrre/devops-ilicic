terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_storage_account" "bad_demo" {
  name                     = "badcheckovdemo12345"
  resource_group_name      = "rg-demo"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Intentionally insecure for Checkov demo only.
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_0"

  shared_access_key_enabled = true

  tags = {
    purpose = "checkov-demo-broken-resource"
  }
}
