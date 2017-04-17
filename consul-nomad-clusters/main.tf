variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "os_user_password" {}

provider "azurerm" {}

#######################################
# Data Sources
#
# Refers to terraform state on local filesystem to
# obtain information about base infrastructure resources
#######################################

data "terraform_remote_state" "base_infrastructure" {
  backend = "local"

  config {
    path = "${path.module}/../base-infrastructure/terraform.tfstate"
  }
}

#######################################
# Inventory West US Cluster
#######################################

module "inventory_westus_cluster" {
  source = "../modules/consul-nomad-cluster"

  # Standard VM parameters
  vm_count            = 1
  resource_group_name = "${data.terraform_remote_state.base_infrastructure.resource_group_name}"
  sa_blob_endpoint    = "${data.terraform_remote_state.base_infrastructure.sa_blob_endpoint_inventory_westus}"
  container_name      = "vhd"
  vm_name             = "consul-inventory-westus"
  vm_location         = ["West US"]
  vm_subnet_id        = ["${data.terraform_remote_state.base_infrastructure.subnet_id_inventory_westus}"]
  vm_size             = "Standard_D2_v2"
  os_user_name        = "ubuntu"
  os_user_password    = "${var.os_user_password}"
  env_tag             = "consul-inventory-westus"

  # Template and other implementation-specific parameters
  client_id          = "${var.client_id}"
  client_secret      = "${var.client_secret}"
  tenant_id          = "${var.tenant_id}"
  nomad_cluster_size = 3
  wan_env_tag        = "consul"
}

#######################################
# Inventory East US Cluster
#######################################

module "inventory_eastus_cluster" {
  source = "../modules/consul-nomad-cluster"

  # Standard VM parameters
  vm_count            = 1
  resource_group_name = "${data.terraform_remote_state.base_infrastructure.resource_group_name}"
  sa_blob_endpoint    = "${data.terraform_remote_state.base_infrastructure.sa_blob_endpoint_inventory_eastus}"
  container_name      = "vhd"
  vm_name             = "consul-inventory-eastus"
  vm_location         = ["East US"]
  vm_subnet_id        = ["${data.terraform_remote_state.base_infrastructure.subnet_id_inventory_eastus}"]
  vm_size             = "Standard_D2_v2"
  os_user_name        = "ubuntu"
  os_user_password    = "${var.os_user_password}"
  env_tag             = "consul-inventory-eastus"

  # Template and other implementation-specific parameters
  client_id          = "${var.client_id}"
  client_secret      = "${var.client_secret}"
  tenant_id          = "${var.tenant_id}"
  nomad_cluster_size = 3
  wan_env_tag        = "consul"
}

#######################################
# Checkout West US 2 Cluster
#######################################

module "checkout_westus2_cluster" {
  source = "../modules/consul-nomad-cluster"

  # Standard VM parameters
  vm_count            = 1
  resource_group_name = "${data.terraform_remote_state.base_infrastructure.resource_group_name}"
  sa_blob_endpoint    = "${data.terraform_remote_state.base_infrastructure.sa_blob_endpoint_checkout_westus2}"
  container_name      = "vhd"
  vm_name             = "consul-checkout-westus2"
  vm_location         = ["West US 2"]
  vm_subnet_id        = ["${data.terraform_remote_state.base_infrastructure.subnet_id_checkout_westus2}"]
  vm_size             = "Standard_D2_v2"
  os_user_name        = "ubuntu"
  os_user_password    = "${var.os_user_password}"
  env_tag             = "consul-checkout-westus2"

  # Template and other implementation-specific parameters
  client_id          = "${var.client_id}"
  client_secret      = "${var.client_secret}"
  tenant_id          = "${var.tenant_id}"
  nomad_cluster_size = 3
  wan_env_tag        = "consul"
}
