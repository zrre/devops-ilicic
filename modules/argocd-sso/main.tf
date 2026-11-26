# Microsoft Entra ID App Registration

resource "azuread_application" "argocd" {
  display_name     = var.application_name
  sign_in_audience = "AzureADMyOrg"

  owners = var.owner_object_ids

  group_membership_claims = [
    "ApplicationGroup"
  ]

  web {
    redirect_uris = [
      "${var.argocd_url}/auth/callback"
    ]
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Enterprise Application

resource "azuread_service_principal" "argocd" {
  client_id                    = azuread_application.argocd.client_id
  app_role_assignment_required = true

  owners = var.owner_object_ids

  lifecycle {
    prevent_destroy = true
  }
}

# AKS Workload Identity Federation

resource "azuread_application_federated_identity_credential" "argocd" {
  application_id = azuread_application.argocd.id

  display_name = "argocd-server-aks"
  description  = "Argo CD server workload identity federation"

  audiences = [
    "api://AzureADTokenExchange"
  ]

  issuer = var.oidc_issuer_url

  subject = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

# Administrator security group

resource "azuread_group" "admins" {
  display_name     = "${var.application_name}-admins"
  description      = "Argo CD administrators"
  security_enabled = true
  mail_enabled     = false

  owners = var.owner_object_ids
}

# Log viewer security group

resource "azuread_group" "log_viewers" {
  display_name     = "${var.application_name}-log-viewers"
  description      = "Argo CD read-only application log viewers"
  security_enabled = true
  mail_enabled     = false

  owners = var.owner_object_ids
}

# Group memberships

resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.admins.object_id
  member_object_id = var.admin_user_object_id
}

resource "azuread_group_member" "tester" {
  group_object_id  = azuread_group.log_viewers.object_id
  member_object_id = var.tester_user_object_id
}

# Assign administrator group to Enterprise Application

resource "azuread_app_role_assignment" "admins" {
  app_role_id = "00000000-0000-0000-0000-000000000000"

  principal_object_id = azuread_group.admins.object_id
  resource_object_id  = azuread_service_principal.argocd.object_id
}

# Assign log viewers group to Enterprise Application

resource "azuread_app_role_assignment" "log_viewers" {
  app_role_id = "00000000-0000-0000-0000-000000000000"

  principal_object_id = azuread_group.log_viewers.object_id
  resource_object_id  = azuread_service_principal.argocd.object_id
}