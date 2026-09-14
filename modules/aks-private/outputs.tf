output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.this.private_fqdn
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}

output "control_plane_principal_id" {
  value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_id" {
  value = azurerm_user_assigned_identity.kubelet.id
}

output "kubelet_principal_id" {
  value = azurerm_user_assigned_identity.kubelet.principal_id
}

output "user_node_pool_id" {
  description = "Resource ID of the AKS user node pool."
  value       = azurerm_kubernetes_cluster_node_pool.user.id
}

output "user_node_pool_name" {
  description = "Name of the AKS user node pool."
  value       = azurerm_kubernetes_cluster_node_pool.user.name
}

output "key_vault_csi_client_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "key_vault_csi_object_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "key_vault_csi_identity_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].user_assigned_identity_id
}