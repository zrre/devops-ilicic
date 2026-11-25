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