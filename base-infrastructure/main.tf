variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "os_user_password" {}
variable "vpn_shared_key" {}

provider "azurerm" {}

#######################################
# Create Resource Group
#######################################

module "resource_group" {
  source   = "../modules/resource_group"
  name     = "Azure-Demo"
  location = "West US"
}

#######################################
# Create Storage Resources
#######################################

module "inventory_westus_storage" {
  source                = "../modules/storage"
  storage_account_name  = "invwestussa"
  location              = "West US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

module "inventory_eastus_storage" {
  source                = "../modules/storage"
  storage_account_name  = "inveastussa"
  location              = "East US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

module "checkout_westus2_storage" {
  source                = "../modules/storage"
  storage_account_name  = "chkwestus2sa"
  location              = "West US 2"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

#######################################
# Create Network Resources
#######################################

module "inventory_westus_network" {
  source              = "../modules/network"
  name                = "inventory-westus"
  location            = "West US"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "inventory-westus"
  resource_group_name = "${module.resource_group.name}"
}

module "inventory_eastus_network" {
  source              = "../modules/network"
  name                = "inventory-eastus"
  location            = "East US"
  address_space       = ["10.1.0.0/16"]
  address_prefix      = "10.1.2.0/24"
  env_tag             = "inventory-eastus"
  resource_group_name = "${module.resource_group.name}"
}

module "checkout_westus2_network" {
  source              = "../modules/network"
  name                = "checkout-westus2"
  location            = "West US 2"
  address_space       = ["10.2.0.0/16"]
  address_prefix      = "10.2.2.0/24"
  env_tag             = "checkout-westus2"
  resource_group_name = "${module.resource_group.name}"
}

#######################################
# Create Bastion Host
#######################################

module "bastion_westus" {
  source = "../modules/bastion"

  # Standard VM parameters
  vm_count            = 1
  resource_group_name = "${module.resource_group.name}"
  sa_blob_endpoint    = "${module.inventory_westus_storage.primary_blob_endpoint}"
  container_name      = "${module.inventory_westus_storage.container_name}"
  vm_name             = "bastion-westus"
  vm_location         = ["West US"]
  vm_subnet_id        = ["${module.inventory_westus_network.subnet_id}"]
  vm_size             = "Standard_A1_v2"
  os_user_name        = "ubuntu"
  os_user_password    = "${var.os_user_password}"
  env_tag             = "bastion-host"

  # Template and other implementation-specific parameters
  client_id                    = "${var.client_id}"
  client_secret                = "${var.client_secret}"
  tenant_id                    = "${var.tenant_id}"
  vn_gw_name                   = "vn-gw"
  vn_name_westus               = "${module.inventory_westus_network.vn_name}"
  vn_gw_address_prefix_westus  = "10.0.1.0/24"
  vn_name_eastus               = "${module.inventory_eastus_network.vn_name}"
  vn_gw_address_prefix_eastus  = "10.1.1.0/24"
  vn_name_westus2              = "${module.checkout_westus2_network.vn_name}"
  vn_gw_address_prefix_westus2 = "10.2.1.0/24"
  vpn_shared_key               = "${var.vpn_shared_key}"
}
