#######################################
# Standard Virtual Machine Variables
#######################################
variable "resource_group_name" {
  type        = "string"
  description = "The name of the resource group in which to create the virtual network resources"
}

variable "name" {
  type        = "string"
  description = "The prefix to add to network resources"
}

variable "location" {
  type        = "string"
  description = "The location for the Virtual Network resources"
}

variable "address_space" {
  type        = "list"
  description = "The address space of the Virtual Network"
}

variable "address_prefix" {
  type        = "string"
  description = "The CIDR range for the subnet"
}

variable "env_tag" {
  type        = "string"
  description = "The cluster name to tag resources with"
}

#######################################
# Outputs
#######################################

output "vn_name" {
  value = "${azurerm_virtual_network.demo_vn.name}"
}

output "subnet_id" {
  value = "${azurerm_subnet.demo_subnet.id}"
}
