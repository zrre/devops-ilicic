resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  namespace        = var.namespace
  create_namespace = false

  take_ownership  = var.take_ownership
  force_update    = false
  cleanup_on_fail = false
  atomic          = false

  wait    = true
  timeout = 600

  values = concat(
    [
      file("${path.module}/helm-values.yaml")
    ],
    var.sso_enabled ? [
      yamlencode(local.sso_values)
    ] : []
  )

  lifecycle {
    prevent_destroy = true
  }
}