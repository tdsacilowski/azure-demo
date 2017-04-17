output "inventory_westus_public_ip" {
  value = "${module.inventory_westus_cluster.public_ip}"
}

output "inventory_eastus_public_ip" {
  value = "${module.inventory_eastus_cluster.public_ip}"
}

output "checkout_westus2_public_ip" {
  value = "${module.checkout_westus2_cluster.public_ip}"
}

#output "configuration" {
#  value = <<CONFIGURATION
#
#CONFIGURATION
#}

