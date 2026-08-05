variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_resource_group_name" {
  type = string
}

variable "node_subnet_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.240.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.240.0.10"
}

variable "tags" {
  type    = map(string)
  default = {}
}
