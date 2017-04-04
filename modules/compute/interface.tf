variable "name" {
  type        = "string"
  description = "The prefix to add to virtual machine resources"
}

variable "location" {
  type        = "list"
  description = "The location(s) for the Virtual Network"
}

variable "vms_per_region" {
  type        = "string"
  description = "The number of VMs to create in each region"
}

variable "resource_group_name" {
  type        = "string"
  description = "The name of the resource group in which to create the virtual network"
}

variable "client_id" {
  type        = "string"
  description = "The client_id to use for authenticating on the Azure CLI"
}

variable "client_secret" {
  type        = "string"
  description = "The client_secret to use for authenticating on the Azure CLI"
}

variable "tenant_id" {
  type        = "string"
  description = "The tenant_id to use for authenticating on the Azure CLI"
}

variable "node_name" {
  type        = "list"
  description = "The name(s) to use to identify each Consul node within the Consul cluster"
}

variable "public_nic" {
  type        = "list"
  description = "The IDs of the Network Interfaces with Public IPs"
}

variable "public_ip" {
  type        = "list"
  description = "The Public IP(s) created"
}

variable "public_fqdn" {
  type        = "list"
  description = "The Public FQDN(s) associated with the Public IP(s) created"
}

variable "storage_account" {
  type        = "list"
  description = "The Storage Account(s) to use to place VHD storage containers for each VM"
}

variable "container_name" {
  type        = "list"
  description = "The name of the Storage Container(s) in which to store VHDs"
}

variable "env_tag" {
  type        = "string"
  description = "The cluster name to tag resources with"
}
