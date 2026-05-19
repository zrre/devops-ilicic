variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_name" {
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

variable "acr_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vm_size" {
  type = string
}

variable "acr_login_server" {
  type = string
}