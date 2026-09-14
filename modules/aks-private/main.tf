resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "id-${var.cluster_name}-kubelet"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
}

resource "azurerm_role_assignment" "system_control_plane_network_contributor" {
  scope                = var.system_node_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "system_control_plane_user_pool_network_contributor" {
  scope                = var.user_node_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "system_control_plane_managed_identity_operator" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix                        = var.dns_prefix
  node_resource_group               = var.node_resource_group_name
  role_based_access_control_enabled = true

  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = "System"

  local_account_disabled = false
  sku_tier               = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = var.system_node_subnet_id

    os_sku                       = "Ubuntu"
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"

    upgrade_settings {
      max_surge = "10%"
    }

    tags = var.tags
  }

  identity {
    type = "SystemAssigned"

  }


  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"

    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"

    pod_cidr       = var.pod_cidr
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.kubelet_acr_pull,
  ]
}
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  mode           = "User"
  vm_size        = var.user_node_pool_vm_size
  node_count     = var.user_node_pool_node_count
  max_pods       = var.user_node_pool_max_pods
  vnet_subnet_id = var.user_node_subnet_id

  temporary_name_for_rotation = "userpooltmp"

  os_type                = "Linux"
  node_public_ip_enabled = false

  upgrade_settings {
    max_surge                     = "10%"
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
  }
}

resource "azurerm_role_assignment" "key_vault_csi_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
  principal_type       = "ServicePrincipal"
}