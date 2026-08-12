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

variable "system_node_subnet_id" {
  description = "Subnet ID used by the AKS system node pool."
  type        = string
}

variable "user_node_subnet_id" {
  description = "Subnet ID used by the AKS user node pool."
  type        = string
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

variable "user_node_pool_name" {
  description = "Name of the AKS user node pool."
  type        = string
  default     = "userpool"
}

variable "user_node_pool_vm_size" {
  description = "VM size used by the AKS user node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "user_node_pool_node_count" {
  description = "Number of nodes in the AKS user node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.user_node_pool_node_count >= 1
    error_message = "The user node pool must contain at least one node."
  }
}

variable "user_node_pool_max_pods" {
  description = "Maximum number of pods per user node."
  type        = number
  default     = 50
}