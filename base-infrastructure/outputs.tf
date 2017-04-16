output "bastion_public_ip" {
  value = "${module.bastion_westus.public_ip}"
}

output "resource_group_name" {
  value = "${module.resource_group.name}"
}

output "sa_blob_endpoint_inventory_westus" {
  value = "${module.inventory_westus_storage.primary_blob_endpoint}"
}

output "subnet_id_inventory_westus" {
  value = "${module.inventory_westus_network.subnet_id}"
}

output "sa_blob_endpoint_inventory_eastus" {
  value = "${module.inventory_eastus_storage.primary_blob_endpoint}"
}

output "subnet_id_inventory_eastus" {
  value = "${module.inventory_eastus_network.subnet_id}"
}

output "sa_blob_endpoint_checkout_westus2" {
  value = "${module.checkout_westus2_storage.primary_blob_endpoint}"
}

output "subnet_id_checkout_westus2" {
  value = "${module.checkout_westus2_network.subnet_id}"
}

#output "configuration" {
#  value = <<CONFIGURATION
#
#CONFIGURATION
#}

