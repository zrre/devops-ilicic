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
  type    = string
  default = "Standard_B2s_v2"
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "subnet_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "aks_cluster_id" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}

variable "aks_resource_group_name" {
  type = string
}

variable "aks_private_fqdn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
