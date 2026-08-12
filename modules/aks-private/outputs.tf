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

output "control_plane_identity_id" {
  value = azurerm_user_assigned_identity.control_plane.id
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