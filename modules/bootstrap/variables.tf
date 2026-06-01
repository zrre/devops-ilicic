variable "resource_group_name" {
  type = string
}

variable "allowed_public_ips" {
  description = "Public IPs allowed to access the Terraform state storage account."
  type        = list(string)
  default     = []
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_container_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
