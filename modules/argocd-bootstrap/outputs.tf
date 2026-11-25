output "appproject_name" {
  description = "Argo CD AppProject name."
  value       = kubernetes_manifest.appproject.manifest.metadata.name
}

output "applicationset_name" {
  description = "Argo CD ApplicationSet name."
  value       = kubernetes_manifest.applicationset.manifest.metadata.name
}

output "namespace" {
  description = "Argo CD namespace."
  value       = kubernetes_manifest.applicationset.manifest.metadata.namespace
}