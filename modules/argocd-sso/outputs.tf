output "tenant_id" {
  description = "Microsoft Entra ID tenant ID."
  value       = var.tenant_id
}

output "client_id" {
  description = "Argo CD application client ID."
  value       = azuread_application.argocd.client_id
}

output "application_object_id" {
  description = "Argo CD App Registration object ID."
  value       = azuread_application.argocd.object_id
}

output "service_principal_object_id" {
  description = "Argo CD Enterprise Application object ID."
  value       = azuread_service_principal.argocd.object_id
}

output "admin_group_id" {
  description = "Argo CD administrator group object ID."
  value       = azuread_group.admins.object_id
}

output "log_viewer_group_id" {
  description = "Argo CD log viewer group object ID."
  value       = azuread_group.log_viewers.object_id
}

output "oidc_issuer" {
  description = "Microsoft Entra ID OIDC issuer."
  value       = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
}

output "redirect_uri" {
  description = "Argo CD OIDC callback URL."
  value       = "${var.argocd_url}/auth/callback"
}