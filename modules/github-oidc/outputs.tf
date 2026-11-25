output "client_id" {
  description = "GitHub Actions application client ID."
  value       = azuread_application.github.client_id
}

output "tenant_id" {
  description = "Microsoft Entra ID tenant ID."
  value       = var.tenant_id
}

output "subscription_id" {
  description = "Azure subscription ID."
  value       = var.subscription_id
}

output "application_object_id" {
  description = "Entra ID application object ID."
  value       = azuread_application.github.object_id
}

output "service_principal_object_id" {
  description = "Entra ID service principal object ID."
  value       = azuread_service_principal.github.object_id
}

output "federated_subject" {
  description = "Trusted GitHub OIDC subject."
  value       = azuread_application_federated_identity_credential.github.subject
}

output "github_environment" {
  description = "Trusted GitHub Actions environment."
  value       = var.github_environment
}