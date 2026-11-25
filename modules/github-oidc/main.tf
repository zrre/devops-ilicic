resource "azuread_application" "github" {
  display_name     = var.application_name
  sign_in_audience = "AzureADMyOrg"

  owners = var.owner_object_ids

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_service_principal" "github" {
  client_id = azuread_application.github.client_id

  owners = var.owner_object_ids

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_application_federated_identity_credential" "github" {
  application_id = azuread_application.github.id

  display_name = "github-${var.github_environment}"

  description = "GitHub Actions OIDC federation for ${var.github_environment}"

  audiences = [
    "api://AzureADTokenExchange"
  ]

  issuer = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_repository}:environment:${var.github_environment}"
}

resource "azurerm_role_assignment" "reader" {
  for_each = var.reader_scopes

  scope                = each.value
  role_definition_name = "Reader"

  principal_id = azuread_service_principal.github.object_id

  principal_type = "ServicePrincipal"

  skip_service_principal_aad_check = true
}