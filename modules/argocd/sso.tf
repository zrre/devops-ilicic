locals {
  sso_values = {
    configs = {
      cm = {
        "admin.enabled"           = true
        "users.anonymous.enabled" = false
        "exec.enabled"            = false

        "oidc.config" = yamlencode({
          name     = "Microsoft Entra ID"
          issuer   = var.sso_oidc_issuer
          clientID = var.sso_client_id

          azure = {
            useWorkloadIdentity = true
          }

          requestedIDTokenClaims = {
            groups = {
              essential = true
              value     = "ApplicationGroup"
            }
          }

          requestedScopes = [
            "openid",
            "profile",
            "email"
          ]
        })
      }

      rbac = {
        create             = true
        "policy.default"   = "role:authenticated"
        "policy.matchMode" = "glob"
        scopes             = "[groups]"

        "policy.csv" = <<-EOT
          p, role:log-viewer, applications, get, training/*, allow
          p, role:log-viewer, logs, get, training/*, allow

          g, ${var.sso_admin_group_id}, role:admin
          g, ${var.sso_log_viewer_group_id}, role:log-viewer
        EOT
      }
    }

    server = {
      podLabels = {
        "azure.workload.identity/use" = "true"
      }

      serviceAccount = {
        create = true
        name   = "argocd-server"

        annotations = {
          "azure.workload.identity/client-id" = var.sso_client_id
          "azure.workload.identity/tenant-id" = var.sso_tenant_id
        }
      }
    }
  }
}