# Configure the Microsoft Azure provider
#
# Assumes the following environment vars are set:
#    ARM_SUBSCRIPTION_ID
#    ARM_CLIENT_ID
#    ARM_CLIENT_SECRET
#    ARM_TENANT_ID
#
provider "azurerm" {}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Create a resource group
module "resource_group" {
  source = "./modules/resource_group"

  name     = "Azure-Demo"
  location = "West US"
}

#######################################
# Inventory Cluster: DC1 (West US)
#######################################

# Create storage for VHDs
module "inventory_dc1_storage" {
  source = "./modules/storage"

  resource_group_name  = "${module.resource_group.name}"
  storage_account_name = "inventorydc1sa"
  location             = "West US"
  account_type         = "Standard_LRS"

  container_access_type = "private"
  container_name        = "vhd"
}

# Create network resources
module "inventory_dc1_networking" {
  source = "./modules/networking"

  vms_per_cluster     = 3
  name                = "inventory-dc1"
  location            = "West US"
  resource_group_name = "${module.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "inventory-dc1"
}

# Launch Consul/Nomad cluster(s)
module "inventory_dc1_compute" {
  source = "./modules/compute"

  name                = "inventory-dc1-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id     = "${var.tenant_id}"
  location      = "West US"

  public_nic      = "${module.inventory_dc1_networking.public_nic_id}"
  public_ip       = "${module.inventory_dc1_networking.public_ip}"
  public_fqdn     = "${module.inventory_dc1_networking.public_fqdn}"
  node_name       = "${module.inventory_dc1_networking.public_fqdn}"
  storage_account = "${module.inventory_dc1_storage.primary_blob_endpoint}"
  container_name  = "${module.inventory_dc1_storage.container_name}"

  # This will be appended with Azure region/location (i.e. consul-cluster-westus).
  # It will be used for the Consul datacenter name, and will also be used by the
  # Azure CLI to query for other VMs in the same datacentef for Consul auto-join
  env_tag = "inventory-dc1"
}

#######################################
# Inventory Cluster: DC2 (East US)
#######################################

# Create storage for VHDs
module "inventory_dc2_storage" {
  source = "./modules/storage"

  resource_group_name  = "${module.resource_group.name}"
  storage_account_name = "inventorydc2sa"
  location             = "East US"
  account_type         = "Standard_LRS"

  container_access_type = "private"
  container_name        = "vhd"
}

# Create network resources
module "inventory_dc2_networking" {
  source = "./modules/networking"

  vms_per_cluster     = 3
  name                = "inventory-dc2"
  location            = "East US"
  resource_group_name = "${module.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "inventory-dc2"
}

# Launch Consul/Nomad cluster(s)
module "inventory_dc2_compute" {
  source = "./modules/compute"

  name                = "inventory-dc2-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id     = "${var.tenant_id}"
  location      = "East US"

  public_nic      = "${module.inventory_dc2_networking.public_nic_id}"
  public_ip       = "${module.inventory_dc2_networking.public_ip}"
  public_fqdn     = "${module.inventory_dc2_networking.public_fqdn}"
  node_name       = "${module.inventory_dc2_networking.public_fqdn}"
  storage_account = "${module.inventory_dc2_storage.primary_blob_endpoint}"
  container_name  = "${module.inventory_dc2_storage.container_name}"
  env_tag         = "inventory-dc2"
}

#######################################
# Checkout Cluster: DC2 (West US 2)
#######################################

# Create storage for VHDs
module "checkout_dc1_storage" {
  source = "./modules/storage"

  resource_group_name  = "${module.resource_group.name}"
  storage_account_name = "checkoutdc1sa"
  location             = "West US 2"
  account_type         = "Standard_LRS"

  container_access_type = "private"
  container_name        = "vhd"
}

# Create network resources
module "checkout_dc1_networking" {
  source = "./modules/networking"

  vms_per_cluster     = 3
  name                = "checkout-dc1"
  location            = "West US 2"
  resource_group_name = "${module.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "checkout-dc1"
}

# Launch Consul/Nomad cluster(s)
module "checkout_dc1_compute" {
  source = "./modules/compute"

  name                = "checkout-dc1-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id     = "${var.tenant_id}"
  location      = "West US 2"

  public_nic      = "${module.checkout_dc1_networking.public_nic_id}"
  public_ip       = "${module.checkout_dc1_networking.public_ip}"
  public_fqdn     = "${module.checkout_dc1_networking.public_fqdn}"
  node_name       = "${module.checkout_dc1_networking.public_fqdn}"
  storage_account = "${module.checkout_dc1_storage.primary_blob_endpoint}"
  container_name  = "${module.checkout_dc1_storage.container_name}"
  env_tag         = "checkout-dc1"
}

output "inventory_dc1_public_ip" {
  value = "${module.inventory_dc1_networking.public_ip}"
}

output "inventory_dc1_public_fqdn" {
  value = "${module.inventory_dc1_networking.public_fqdn}"
}

output "inventory_dc2_public_ip" {
  value = "${module.inventory_dc2_networking.public_ip}"
}

output "inventory_dc2_public_fqdn" {
  value = "${module.inventory_dc2_networking.public_fqdn}"
}

output "checkout_dc1_public_ip" {
  value = "${module.checkout_dc1_networking.public_ip}"
}

output "checkout_dc1_public_fqdn" {
  value = "${module.checkout_dc1_networking.public_fqdn}"
}
