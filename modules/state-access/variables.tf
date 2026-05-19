variable "storage_account_name" {
  type = string
}

variable "storage_resource_group_name" {
  type = string
}

variable "allowed_public_ips" {
  type = list(string)
}

variable "allowed_subnet_ids" {
  type = list(string)
}
