resource "kubernetes_manifest" "appproject" {
  manifest = yamldecode(var.appproject_manifest)

  field_manager {
    name            = "terraform"
    force_conflicts = false
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_manifest" "applicationset" {
  manifest = yamldecode(var.applicationset_manifest)

  field_manager {
    name            = "terraform"
    force_conflicts = false
  }

  depends_on = [
    kubernetes_manifest.appproject
  ]

  lifecycle {
    prevent_destroy = true
  }
}