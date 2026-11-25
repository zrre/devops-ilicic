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

dependency "argocd_sso" {
  config_path = "../argocd-sso"
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

  sso_enabled = true

  sso_tenant_id = dependency.argocd_sso.outputs.tenant_id

  sso_client_id = dependency.argocd_sso.outputs.client_id

  sso_oidc_issuer = dependency.argocd_sso.outputs.oidc_issuer

  sso_admin_group_id = dependency.argocd_sso.outputs.admin_group_id

  sso_log_viewer_group_id = dependency.argocd_sso.outputs.log_viewer_group_id
}