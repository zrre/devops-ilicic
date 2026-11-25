variable "tenant_id" {
  description = "Microsoft Entra ID tenant ID."
  type        = string
}

variable "application_name" {
  description = "Name of the Argo CD App Registration."
  type        = string
}

variable "argocd_url" {
  description = "External Argo CD HTTPS URL."
  type        = string
}

variable "oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  type        = string
}

variable "admin_user_object_id" {
  description = "Entra ID object ID of the administrator."
  type        = string
}

variable "tester_user_object_id" {
  description = "Entra ID object ID of the log viewer."
  type        = string
}

variable "namespace" {
  description = "Argo CD Kubernetes namespace."
  type        = string
  default     = "argocd"
}

variable "service_account_name" {
  description = "Argo CD server service account."
  type        = string
  default     = "argocd-server"
}