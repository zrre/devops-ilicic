variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_public_key" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "allowed_ssh_public_ips" {
  type = list(string)
}

variable "github_repo_url" {
  type = string
}

variable "github_runner_token" {
  type      = string
  sensitive = true
}

variable "github_runner_labels" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
