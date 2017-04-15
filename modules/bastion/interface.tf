#######################################
# Standard Virtual Machine Variables
#######################################

variable "resource_group_name" {
  type        = "string"
  description = "The name of the resource group in which to create the virtual machine"
}

variable "storage_account" {
  type        = "string"
  description = "The Storage Account to use to place VHD storage containers for each VM"
}

variable "container_name" {
  type        = "string"
  description = "The name of the Storage Container in which to store VHDs"
}

variable "vm_name" {
  type        = "string"
  description = "The prefix to add to the virtual machine and related resources"
}

variable "vm_location" {
  type        = "string"
  description = "The location (region) for the virtual machine"
}

variable "vm_subnet_id" {
  type        = "string"
  description = "The id of the VN subnet in which to create the virual machine"
}

variable "vm_size" {
  type        = "string"
  description = "The size.class of virtual machine to create"
}

variable "os_user_name" {
  type        = "string"
  description = "The the default user to create on the virtual machine"
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
variable "vn_gw_name" {}
variable "vn_name_westus" {}
variable "vn_gw_address_prefix_westus" {}
variable "vn_name_eastus" {}
variable "vn_gw_address_prefix_eastus" {}
variable "vn_name_westus2" {}
variable "vn_gw_address_prefix_westus2" {}
variable "vpn_shared_key" {}

#######################################
# Outputs
#######################################

output "public_ip" {
  value = "${azurerm_public_ip.vm_pub_ip.ip_address}"
}
