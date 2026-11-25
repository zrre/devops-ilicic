output "release_name" {
  description = "Argo CD bootstrap Helm release."
  value       = helm_release.bootstrap.name
}

output "appproject_name" {
  description = "Argo CD AppProject name."
  value       = yamldecode(var.appproject_manifest).metadata.name
}

output "applicationset_name" {
  description = "Argo CD ApplicationSet name."
  value       = yamldecode(var.applicationset_manifest).metadata.name
}

output "namespace" {
  description = "Argo CD namespace."
  value       = helm_release.bootstrap.namespace
}