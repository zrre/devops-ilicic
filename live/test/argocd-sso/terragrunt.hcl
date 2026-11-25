include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "aks" {
  config_path = "../aks"

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
  ]

  mock_outputs_merge_strategy_with_state = "shallow"

  mock_outputs = {
    oidc_issuer_url = dependency.aks.outputs.oidc_issuer_url
  }
}

terraform {
  source = "../../../modules/argocd-sso"
}

inputs = {
  tenant_id = "b2748d0a-856e-4184-bda8-831f9ffa8a48"

  application_name = "argocd-ilicic-test"

  argocd_url = "https://argo.zrre.net"

  oidc_issuer_url = dependency.aks.outputs.oidc_issuer_url

  admin_user_object_id = "5c27445f-9051-4cbb-864e-b8024dfd232c"

  tester_user_object_id = "05e4fa9c-bb17-442e-825e-086a64c7e717"

  namespace            = "argocd"
  service_account_name = "argocd-server"
}