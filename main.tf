/*
Configure the Microsoft Azure provider

assumes the following environment vars are set:
    ARM_SUBSCRIPTION_ID
    ARM_CLIENT_ID
    ARM_CLIENT_SECRET
    ARM_TENANT_ID
*/
provider "azurerm" {}

variable "client_id" {
  type    = "string"
  default = "[ENTER CLIENT_ID]"
}

variable "client_secret" {
  type    = "string"
  default = "[ENTER CLIENT_SECRET]"
}

variable "tenant_id" {
  type    = "string"
  default = "[ENTER TENANT_ID]"
}

# Create a resource group
module "consul_resource_group" {
  source = "./modules/resource_group"

  name     = "Azure-Demo"
  location = "West US"
}

#######################################
# Consul Cluster(s)
#######################################

variable "consul_cluster_name" {
  type    = "string"
  default = "consul-cluster"
}

variable "consul_cluster_location" {
  type    = "list"
  default = ["West US", "West US 2"]
}

variable "consul_cluster_vms" {
  type    = "string"
  default = 3
}

# VN CIDR block
variable "consul_cluster_vn_address_space" {
  type    = "list"
  default = ["10.0.0.0/16"]
}

# Subnet CIDR block
variable "consul_cluster_subnet_address_prefix" {
  type    = "list"
  default = ["10.0.2.0/24"]
}

# Storage Account name
variable "consul_cluster_sa_name" {
  type    = "string"
  default = "consulcluster"
}

# Create storage for VHDs
module "consul_storage" {
  source = "./modules/storage"

  resource_group_name  = "${module.consul_resource_group.name}"
  storage_account_name = "${var.consul_cluster_sa_name}"
  location             = "${var.consul_cluster_location}"
  account_type         = "Standard_LRS"

  container_access_type = "private"
  container_name        = "vhd"
}

# Create network resources
module "consul_networking" {
  source = "./modules/networking"

  vms_per_cluster     = "${var.consul_cluster_vms}"
  name                = "${var.consul_cluster_name}-vn"
  location            = "${var.consul_cluster_location}"
  resource_group_name = "${module.consul_resource_group.name}"
  address_space       = "${var.consul_cluster_vn_address_space}"
  address_prefix      = "${var.consul_cluster_subnet_address_prefix}"
  env_tag             = "${var.consul_cluster_name}"
}

# Launch Consul/Nomad cluster(s)
module "consul_compute" {
  source = "./modules/compute"

  name                = "${var.consul_cluster_name}-vm"
  resource_group_name = "${module.consul_resource_group.name}"
  vms_per_cluster     = "${var.consul_cluster_vms}"
  client_id           = "${var.client_id}"
  client_secret       = "${var.client_secret}"
  tenant_id           = "${var.tenant_id}"
  location            = "${var.consul_cluster_location}"
  public_nic          = "${module.consul_networking.public_nic_id}"
  public_ip           = "${module.consul_networking.public_ip}"
  public_fqdn         = "${module.consul_networking.public_fqdn}"
  node_name           = "${module.consul_networking.public_fqdn}"
  storage_account     = "${module.consul_storage.primary_blob_endpoint}"
  container_name      = "${module.consul_storage.container_name}"

  # This will be appended with Azure region/location (i.e. consul-cluster-westus).
  # It will be used for the Consul datacenter name, and will also be used by the
  # Azure CLI to query for other VMs in the same datacentef for Consul auto-join
  env_tag = "${var.consul_cluster_name}"
}
