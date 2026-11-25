include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(
    find_in_parent_folders("env.hcl")
  )
}

dependency "aks" {
  config_path = "../aks"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs = {
    cluster_name = "aks-ilicic-devops-test"
  }
}

terraform {
  source = "../../../modules/argocd"
}

inputs = {
  kubeconfig_path = "~/.kube/config"
  kube_context    = "${dependency.aks.outputs.cluster_name}-admin"

  namespace     = "argocd"
  chart_version = "10.11.6"

  take_ownership = false
}