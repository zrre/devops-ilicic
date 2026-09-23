variable "resource_group_name" {
  type = string
}

variable "allowed_public_ips" {
  description = "Public IPs allowed to access the Terraform state storage account."
  type        = list(string)
  default     = []
}

variable "allowed_virtual_network_subnet_ids" {
  description = "Virtual network subnet IDs allowed to access the Terraform state storage account."
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

variable "blob_data_contributor_principal_ids" {
  description = "Principal IDs allowed to read and write Terraform state blobs."
  type        = set(string)
  default     = []
}