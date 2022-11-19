variable "resource_group_name" {
  type        = string
  description = "the resource group to place this vnet in"
}

variable "resource_group_location" {
  type        = string
  description = "location to create vnet in"
}

variable "public_subnet_id" {
  type        = string
  description = "the subnet id to place this vnet in"
}