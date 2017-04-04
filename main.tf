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

variable "location" {
  type    = "list"
  default = ["West US", "West US 2"]
}

variable "vms_per_cluster" {
  type    = "string"
  default = 3
}

# Create a resource group
module "resource_group" {
  source = "./modules/resource_group"

  name     = "AzureDemo"
  location = "${var.location}"
}

# Create network resources
module "networking" {
  source = "./modules/networking"

  vms_per_cluster     = "${var.vms_per_cluster}"
  name                = "demo"
  location            = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = ["10.0.2.0/24"]
  env_tag             = "consul-dc"
}

# Create storage for VHDs
module "storage" {
  source = "./modules/storage"

  resource_group_name  = "${module.resource_group.name}"
  storage_account_name = "azuredemosa"
  location             = "${var.location}"
  account_type         = "Standard_LRS"

  container_access_type = "private"
  container_name        = "vhd"
}

# Launch Consul/Nomad cluster(s)
module "compute" {
  source = "./modules/compute"

  name                = "consul-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = "${var.vms_per_cluster}"
  client_id           = "${var.client_id}"
  client_secret       = "${var.client_secret}"
  tenant_id           = "${var.tenant_id}"
  location            = "${var.location}"
  public_nic          = "${module.networking.public_nic_id}"
  public_ip           = "${module.networking.public_ip}"
  public_fqdn         = "${module.networking.public_fqdn}"
  node_name           = "${module.networking.public_fqdn}"
  storage_account     = "${module.storage.primary_blob_endpoint}"
  container_name      = "${module.storage.container_name}"
  env_tag             = "consul-dc"
}
