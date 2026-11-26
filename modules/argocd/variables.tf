variable "kubeconfig_path" {
  description = "Path to Kubernetes configuration."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context for the target AKS cluster."
  type        = string
}

variable "namespace" {
  description = "Argo CD namespace."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version."
  type        = string
  default     = "10.11.6"
}

variable "take_ownership" {
  description = "Allow Helm to adopt existing Kubernetes resources."
  type        = bool
  default     = false
}

variable "sso_enabled" {
  description = "Enable Microsoft Entra ID SSO."
  type        = bool
  default     = false
}

variable "sso_tenant_id" {
  description = "Microsoft Entra ID tenant ID."
  type        = string
  default     = ""
}

variable "sso_client_id" {
  description = "Microsoft Entra ID application client ID."
  type        = string
  default     = ""
}

variable "sso_oidc_issuer" {
  description = "Microsoft Entra ID OIDC issuer."
  type        = string
  default     = ""
}

variable "sso_admin_group_id" {
  description = "Entra ID administrator group object ID."
  type        = string
  default     = ""
}

variable "sso_log_viewer_group_id" {
  description = "Entra ID log viewer group object ID."
  type        = string
  default     = ""
}