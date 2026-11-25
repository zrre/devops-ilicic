resource "helm_release" "bootstrap" {
  name       = "argocd-bootstrap"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.8"

  namespace        = "argocd"
  create_namespace = false

  atomic          = false
  cleanup_on_fail = false
  force_update    = false
  take_ownership  = false

  wait    = true
  timeout = 300

  values = [
    yamlencode({
      itemTemplates = [
        yamldecode(var.appproject_manifest),
        yamldecode(var.applicationset_manifest)
      ]
    })
  ]

  lifecycle {
    prevent_destroy = true
  }
}