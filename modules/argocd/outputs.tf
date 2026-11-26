output "release_name" {
  description = "Argo CD Helm release name."
  value       = helm_release.argocd.name
}

output "namespace" {
  description = "Argo CD namespace."
  value       = helm_release.argocd.namespace
}

output "chart_version" {
  description = "Installed Argo CD Helm chart version."
  value       = helm_release.argocd.version
}

output "server_service_name" {
  description = "Argo CD server Kubernetes service."
  value       = "argocd-server"
}