provider "azurerm" {}

# Create a resource group
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "Azure-Demo"
  location = "West US"
}

#######################################
# Inventory Cluster: DC1 (West US)
#######################################

# Create storage for VHDs
module "inventory_west_storage" {
  source                = "./modules/storage"
  storage_account_name  = "inventorwestsa"
  location              = "West US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

# Create network resources
module "inventory_west_networking" {
  source              = "./modules/networking"
  consul_cluster_size = 1
  name                = "inventory-west"
  location            = "West US"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "inventory-west"
  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "inventory_west_compute" {
  source              = "./modules/compute"
  name                = "inventory-west-vm"
  consul_cluster_size = 1
  location            = "West US"
  env_tag             = "inventory-west"
  nomad_cluster_size  = "${length(module.inventory_west_networking.public_ip) + length(module.inventory_east_networking.public_ip) + length(module.checkout_dc1_networking.public_ip)}"
  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.inventory_west_networking.public_nic_id}"
  public_ip           = "${module.inventory_west_networking.public_ip}"
  public_fqdn         = "${module.inventory_west_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_west_networking.public_ip, module.inventory_east_networking.public_ip)}"
  node_name           = "${module.inventory_west_networking.public_fqdn}"
  storage_account     = "${module.inventory_west_storage.primary_blob_endpoint}"
  container_name      = "${module.inventory_west_storage.container_name}"
}

#######################################
# Inventory Cluster: DC2 (East US)
#######################################

# Create storage for VHDs
module "inventory_east_storage" {
  source                = "./modules/storage"
  storage_account_name  = "inventoryeastsa"
  location              = "East US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

# Create network resources
module "inventory_east_networking" {
  source              = "./modules/networking"
  consul_cluster_size = 1
  name                = "inventory-east"
  location            = "East US"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "inventory-east"
  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "inventory_east_compute" {
  source              = "./modules/compute"
  name                = "inventory-east-vm"
  consul_cluster_size = 1
  location            = "East US"
  env_tag             = "inventory-east"
  nomad_cluster_size  = "${length(module.inventory_west_networking.public_ip) + length(module.inventory_east_networking.public_ip) + length(module.checkout_dc1_networking.public_ip)}"
  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.inventory_east_networking.public_nic_id}"
  public_ip           = "${module.inventory_east_networking.public_ip}"
  public_fqdn         = "${module.inventory_east_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_west_networking.public_ip, module.inventory_east_networking.public_ip)}"
  node_name           = "${module.inventory_east_networking.public_fqdn}"
  storage_account     = "${module.inventory_east_storage.primary_blob_endpoint}"
  container_name      = "${module.inventory_east_storage.container_name}"
}

#######################################
# Checkout Cluster: DC1 (West US 2)
#######################################

# Create storage for VHDs
module "checkout_dc1_storage" {
  source                = "./modules/storage"
  storage_account_name  = "checkoutdc1sa"
  location              = "West US 2"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"
  resource_group_name   = "${module.resource_group.name}"
}

# Create network resources
module "checkout_dc1_networking" {
  source              = "./modules/networking"
  consul_cluster_size = 1
  name                = "checkout-dc1"
  location            = "West US 2"
  address_space       = ["10.0.0.0/16"]
  address_prefix      = "10.0.2.0/24"
  env_tag             = "checkout-dc1"
  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "checkout_dc1_compute" {
  source              = "./modules/compute"
  name                = "checkout-dc1-vm"
  consul_cluster_size = 1
  location            = "West US 2"
  env_tag             = "checkout-dc1"
  nomad_cluster_size  = "${length(module.inventory_west_networking.public_ip) + length(module.inventory_east_networking.public_ip) + length(module.checkout_dc1_networking.public_ip)}"
  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.checkout_dc1_networking.public_nic_id}"
  public_ip           = "${module.checkout_dc1_networking.public_ip}"
  public_fqdn         = "${module.checkout_dc1_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_west_networking.public_ip, module.inventory_east_networking.public_ip)}"
  node_name           = "${module.checkout_dc1_networking.public_fqdn}"
  storage_account     = "${module.checkout_dc1_storage.primary_blob_endpoint}"
  container_name      = "${module.checkout_dc1_storage.container_name}"
}
