variable "private_dns_zone_resource_group_name" {
  description = "Resource group containing the private DNS zones."
  type        = string
}

variable "private_dns_zone_names" {
  description = "Private DNS zones that will be linked to the target VNet."
  type        = list(string)
}

variable "virtual_network_id" {
  description = "ID of the VNet that needs private DNS resolution."
  type        = string
}

variable "virtual_network_link_name" {
  description = "Name used for the VNet link inside each private DNS zone."
  type        = string
}

variable "tags" {
  description = "Tags applied to the private DNS VNet links."
  type        = map(string)
  default     = {}
}
