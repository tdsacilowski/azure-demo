variable "name" {
  type        = "string"
  description = "The name of the resource group to create"
}

variable "location" {
  type        = "list"
  description = "The location(s) in which to create the resource group"
}

output "name" {
  value = "${azurerm_resource_group.demo.name}"
}
