variable "name" {
  type        = "string"
  description = "The prefix to add to network resources"
}

variable "location" {
  type        = "string"
  description = "The location for the Virtual Network resources"
}

variable "vms_per_cluster" {
  type        = "string"
  description = "The number of VMs to create in each region"
}

variable "resource_group_name" {
  type        = "string"
  description = "The name of the resource group in which to create the virtual network"
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

output "public_subnet_id" {
  value = "${azurerm_subnet.demo_pub_subnet.id}"
}

output "public_ip" {
  value = ["${azurerm_public_ip.demo_pub_ip.*.ip_address}"]
}

output "public_fqdn" {
  value = ["${azurerm_public_ip.demo_pub_ip.*.fqdn}"]
}

output "public_ip_id" {
  value = ["${azurerm_public_ip.demo_pub_ip.*.id}"]
}

output "public_nic_id" {
  value = ["${azurerm_network_interface.demo_pub_nic.*.id}"]
}
