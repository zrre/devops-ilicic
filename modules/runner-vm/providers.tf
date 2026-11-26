terraform {
  required_version = ">= 1.6.0"


  required_providers {
    azurerm = {
      source  = "registry.opentofu.org/hashicorp/azurerm"
      version = "~> 4.72"
    }
  }
}

provider "azurerm" {
  features {}
}
