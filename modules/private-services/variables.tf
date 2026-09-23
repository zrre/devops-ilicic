variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "artifact_cache_enabled" {
  type    = bool
  default = false
}

variable "artifact_cache_credential_set_name" {
  type    = string
  default = "DockerHubCreds"
}

variable "artifact_cache_login_server" {
  type    = string
  default = "docker.io"
}

variable "artifact_cache_username_secret_id" {
  type    = string
  default = null
}

variable "artifact_cache_password_secret_id" {
  type    = string
  default = null
}

variable "artifact_cache_rules" {
  type = map(object({
    name        = string
    source_repo = string
    target_repo = string
  }))

  default = {}
}