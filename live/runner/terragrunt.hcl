remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-ilicic-devops-tfstate"
    storage_account_name = "stilicicdevopstf"
    container_name       = "tfstate"
    key                  = "shared/runner.tfstate"
    use_azuread_auth     = true
  }
}

terraform {
  source = "../../modules/runner-vm"
}

inputs = {
  resource_group_name = "rg-ilicic-devops-runner"
  location            = "westeurope"

  vm_name        = "vm-ilicic-github-runner"
  vm_size        = "Standard_B2s_v2"
  admin_username = "azureuser"

  admin_ssh_public_key = file("~/.ssh/id_ed25519.pub")

  allowed_ssh_public_ips = [
    "77.46.241.175",
    "79.175.106.38",
    "178.221.121.217",
    "93.86.182.168"
  ]

  tags = {
    owner       = "znebrigic"
    environment = "shared"
    managed_by  = "terragrunt"
    project     = "ilicic-devops"
    role        = "github-runner"
  }
}
