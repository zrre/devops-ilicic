terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "registry.opentofu.org/hashicorp/azuread"
      version = "~> 3.6.0"
    }

    azurerm = {
      source  = "registry.opentofu.org/hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
  use_cli   = true
}

provider "azurerm" {
  features {}

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  use_cli  = true
  use_oidc = false
}