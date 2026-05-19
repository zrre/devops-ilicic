locals {
  environment = "dev"
  location    = "westeurope"

  acr_name             = "acrilicicdevopsdev"
  app_storage_name     = "stilicicappdevopsdev"
  key_vault_name       = "kv-ilicic-devops-dev"

  test_vm_name         = "vm-ilicic-test-dev"
  test_vm_admin_user   = "azureuser"
  test_vm_size         = "Standard_B2s_v2"

  backend_resource_group_name  = "rg-ilicic-devops-tfstate-dev"
  workload_resource_group_name = "rg-ilicic-devops-dev"

  tfstate_storage_account_name = "stilicicdevopstfstate"
  tfstate_container_name       = "tfstate"

  allowed_public_ips = [
    "77.46.241.175",
    "79.175.106.38"
  ]

  tags = {
    owner       = "znebrigic"
    environment = "dev"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
  }
}
