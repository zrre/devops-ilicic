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

  mock_outputs = {
    cluster_name = "aks-ilicic-devops-test"
  }
}

dependencies {
  paths = [
    "../argocd"
  ]
}

terraform {
  source = "../../../modules/argocd-bootstrap"
}

inputs = {
  kubeconfig_path = "~/.kube/config"
  kube_context    = "${dependency.aks.outputs.cluster_name}-admin"

  appproject_manifest = file(
    "${get_repo_root()}/kubernetes/argocd/appproject.yaml"
  )

  applicationset_manifest = file(
    "${get_repo_root()}/kubernetes/argocd/applicationset.yaml"
  )
}