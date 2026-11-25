variable "kubeconfig_path" {
  description = "Path to Kubernetes configuration."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Target Kubernetes context."
  type        = string
}

variable "appproject_manifest" {
  description = "Argo CD AppProject YAML manifest."
  type        = string
}

variable "applicationset_manifest" {
  description = "Argo CD ApplicationSet YAML manifest."
  type        = string
}