output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "state_container_ids" {
  description = "Resource IDs of environment-specific state containers."

  value = {
    for name, container in azurerm_storage_container.environment :
    name => container.id
  }
}