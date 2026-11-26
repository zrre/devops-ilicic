variable "tenant_id" {
  description = "Microsoft Entra ID tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "application_name" {
  description = "Name of the GitHub Actions application."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format."
  type        = string
}

variable "github_environment" {
  description = "GitHub Actions protected environment."
  type        = string
}

variable "owner_object_ids" {
  description = "Entra ID application owners."
  type        = set(string)
}

variable "reader_scopes" {
  description = "Azure resource scopes for Reader assignments."
  type        = set(string)
  default     = []
}