provider "azurerm" {}

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

  storage_account_name  = "inventorydc1sa"
  location              = "West US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"

  resource_group_name = "${module.resource_group.name}"
}

# Create network resources
module "inventory_dc1_networking" {
  source = "./modules/networking"

  vms_per_cluster = 1
  name            = "inventory-dc1"
  location        = "West US"
  address_space   = ["10.0.0.0/16"]
  address_prefix  = "10.0.2.0/24"
  env_tag         = "inventory-dc1"

  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "inventory_dc1_compute" {
  source = "./modules/compute"

<<<<<<< HEAD
  name                = "inventory-dc1-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3
  location      = "West US"

  public_nic      = "${module.inventory_dc1_networking.public_nic_id}"
  public_ip       = "${module.inventory_dc1_networking.public_ip}"
  public_fqdn     = "${module.inventory_dc1_networking.public_fqdn}"
  node_name       = "${module.inventory_dc1_networking.public_fqdn}"
  storage_account = "${module.inventory_dc1_storage.primary_blob_endpoint}"
  container_name  = "${module.inventory_dc1_storage.container_name}"
=======
  name            = "inventory-dc1-vm"
  vms_per_cluster = 1
  location        = "West US"
>>>>>>> 9c3621665ba8579709c43e1c1e2106f6a6c56645

  # This will be appended with Azure region/location (i.e. consul-cluster-westus).
  # It will be used for the Consul datacenter name, and will also be used by the
  # Azure CLI to query for other VMs in the same datacentef for Consul auto-join
  env_tag = "inventory-dc1"

  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.inventory_dc1_networking.public_nic_id}"
  public_ip           = "${module.inventory_dc1_networking.public_ip}"
  public_fqdn         = "${module.inventory_dc1_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_dc1_networking.public_ip, module.inventory_dc2_networking.public_ip)}"
  node_name           = "${module.inventory_dc1_networking.public_fqdn}"
  storage_account     = "${module.inventory_dc1_storage.primary_blob_endpoint}"
  container_name      = "${module.inventory_dc1_storage.container_name}"
}

#######################################
# Inventory Cluster: DC2 (East US)
#######################################

# Create storage for VHDs
module "inventory_dc2_storage" {
  source = "./modules/storage"

  storage_account_name  = "inventorydc2sa"
  location              = "East US"
  account_type          = "Standard_LRS"
  container_access_type = "private"
  container_name        = "vhd"

  resource_group_name = "${module.resource_group.name}"
}

# Create network resources
module "inventory_dc2_networking" {
  source = "./modules/networking"

  vms_per_cluster = 1
  name            = "inventory-dc2"
  location        = "East US"
  address_space   = ["10.0.0.0/16"]
  address_prefix  = "10.0.2.0/24"
  env_tag         = "inventory-dc2"

  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "inventory_dc2_compute" {
  source = "./modules/compute"

<<<<<<< HEAD
  name                = "inventory-dc2-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3
  location      = "East US"

  public_nic      = "${module.inventory_dc2_networking.public_nic_id}"
  public_ip       = "${module.inventory_dc2_networking.public_ip}"
  public_fqdn     = "${module.inventory_dc2_networking.public_fqdn}"
  node_name       = "${module.inventory_dc2_networking.public_fqdn}"
  storage_account = "${module.inventory_dc2_storage.primary_blob_endpoint}"
  container_name  = "${module.inventory_dc2_storage.container_name}"
=======
  name            = "inventory-dc2-vm"
  vms_per_cluster = 1
  location        = "East US"
>>>>>>> 9c3621665ba8579709c43e1c1e2106f6a6c56645
  env_tag         = "inventory-dc2"

  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.inventory_dc2_networking.public_nic_id}"
  public_ip           = "${module.inventory_dc2_networking.public_ip}"
  public_fqdn         = "${module.inventory_dc2_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_dc1_networking.public_ip, module.inventory_dc2_networking.public_ip)}"
  node_name           = "${module.inventory_dc2_networking.public_fqdn}"
  storage_account     = "${module.inventory_dc2_storage.primary_blob_endpoint}"
  container_name      = "${module.inventory_dc2_storage.container_name}"
}

#######################################
# Checkout Cluster: DC1 (West US 2)
#######################################

# Create storage for VHDs
module "checkout_dc1_storage" {
  source = "./modules/storage"

<<<<<<< HEAD
  resource_group_name  = "${module.resource_group.name}"
  storage_account_name = "checkoutdc1sa"
  location             = "West US 2"
  account_type         = "Standard_LRS"
=======
  storage_account_name  = "checkoutdc1sa"
  location              = "West US 2"
  account_type          = "Standard_LRS"
>>>>>>> 9c3621665ba8579709c43e1c1e2106f6a6c56645
  container_access_type = "private"
  container_name        = "vhd"

  resource_group_name = "${module.resource_group.name}"
}

# Create network resources
module "checkout_dc1_networking" {
  source = "./modules/networking"

  vms_per_cluster = 1
  name            = "checkout-dc1"
  location        = "West US 2"
  address_space   = ["10.0.0.0/16"]
  address_prefix  = "10.0.2.0/24"
  env_tag         = "checkout-dc1"

  resource_group_name = "${module.resource_group.name}"
}

# Launch Consul/Nomad cluster(s)
module "checkout_dc1_compute" {
  source = "./modules/compute"

<<<<<<< HEAD
  name                = "checkout-dc1-vm"
  resource_group_name = "${module.resource_group.name}"
  vms_per_cluster     = 3
  location      = "West US 2"

  public_nic      = "${module.checkout_dc1_networking.public_nic_id}"
  public_ip       = "${module.checkout_dc1_networking.public_ip}"
  public_fqdn     = "${module.checkout_dc1_networking.public_fqdn}"
  node_name       = "${module.checkout_dc1_networking.public_fqdn}"
  storage_account = "${module.checkout_dc1_storage.primary_blob_endpoint}"
  container_name  = "${module.checkout_dc1_storage.container_name}"
=======
  name            = "checkout-dc1-vm"
  vms_per_cluster = 1
  location        = "West US 2"
>>>>>>> 9c3621665ba8579709c43e1c1e2106f6a6c56645
  env_tag         = "checkout-dc1"

  resource_group_name = "${module.resource_group.name}"
  public_nic          = "${module.checkout_dc1_networking.public_nic_id}"
  public_ip           = "${module.checkout_dc1_networking.public_ip}"
  public_fqdn         = "${module.checkout_dc1_networking.public_fqdn}"
  join_wan            = "${concat(module.checkout_dc1_networking.public_ip, module.inventory_dc1_networking.public_ip, module.inventory_dc2_networking.public_ip)}"
  node_name           = "${module.checkout_dc1_networking.public_fqdn}"
  storage_account     = "${module.checkout_dc1_storage.primary_blob_endpoint}"
  container_name      = "${module.checkout_dc1_storage.container_name}"
}
