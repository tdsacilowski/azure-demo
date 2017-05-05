#######################################
# Standard Virtual Machine Variables
#######################################

variable "vm_count" {
  type        = "string"
  description = "The number of virtual machines and associated resources to create"
}

variable "resource_group_name" {
  type        = "string"
  description = "The name of the resource group in which to create the virtual machine(s)"
}

variable "sa_blob_endpoint" {
  type        = "string"
  description = "The Storage Account blob endpoint to use to place VHD storage containers for the virtual machine(s)"
}

variable "container_name" {
  type        = "string"
  description = "The name of the Storage Container in which to store virtual machine VHDs"
}

variable "packer_image_uri" {
  type        = "string"
  description = "The URI for the Hashi-stack (Consul/Nomad/Vault) VM image created by Packer"
}

variable "vm_name" {
  type        = "string"
  description = "The prefix to add to the virtual machine(s) and associated resources"
}

variable "vm_location" {
  type        = "list"
  description = "The location(s) - AKA region(s) - in which to create the virtual machine(s)"
}

variable "vm_subnet_id" {
  type        = "list"
  description = "The ID of the VNet subnet(s) in which to create the virual machine(s)"
}

variable "vm_size" {
  type        = "string"
  description = "The size/class of virtual machine(s) to create"
}

variable "os_user_name" {
  type        = "string"
  description = "The the default user to create on the virtual machine(s)"
}

variable "os_user_password" {
  type        = "string"
  description = "The the default user's password"
}

variable "env_tag" {
  type        = "string"
  description = "The environment tag name"
}

#######################################
# Template Variables
#######################################

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "wan_env_tag" {
  type        = "string"
  description = "The environment tag keyword to look for when joining Consul clusters over WAN"
}

variable "nomad_cluster_size" {
  type        = "string"
  description = "Total number of Nomad servers across all regions"
}

#######################################
# Outputs
#######################################

output "public_ip" {
  value = ["${azurerm_public_ip.vm_pub_ip.*.ip_address}"]
}

output "private_ip" {
  value = ["${azurerm_network_interface.vm_pub_nic.*.private_ip_address}"]
}
