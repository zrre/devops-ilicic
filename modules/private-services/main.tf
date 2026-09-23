data "azurerm_client_config" "current" {}

resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  allow_nested_items_to_be_public = false

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = "appdata"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false

  tags = var.tags
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "link-acr-to-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "link-storage-blob-to-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-keyvault-to-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${var.acr_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.acr_name}"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr.id
    ]
  }

  tags = var.tags
}

resource "azurerm_container_registry_credential_set" "dockerhub" {
  count = var.artifact_cache_enabled ? 1 : 0

  name                  = var.artifact_cache_credential_set_name
  container_registry_id = azurerm_container_registry.this.id
  login_server          = var.artifact_cache_login_server

  identity {
    type = "SystemAssigned"
  }

  authentication_credentials {
    username_secret_id = var.artifact_cache_username_secret_id
    password_secret_id = var.artifact_cache_password_secret_id
  }
}

resource "azurerm_role_assignment" "artifact_cache_key_vault_secrets_user" {
  count = var.artifact_cache_enabled ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_registry_credential_set.dockerhub[0].identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_container_registry_cache_rule" "this" {
  for_each = var.artifact_cache_enabled ? var.artifact_cache_rules : {}

  name                  = each.value.name
  container_registry_id = azurerm_container_registry.this.id

  source_repo = each.value.source_repo
  target_repo = each.value.target_repo

  credential_set_id = azurerm_container_registry_credential_set.dockerhub[0].id

  depends_on = [
    azurerm_role_assignment.artifact_cache_key_vault_secrets_user,
  ]
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-${var.storage_account_name}-blob"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.storage_blob.id
    ]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-${var.key_vault_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }

  tags = var.tags
}