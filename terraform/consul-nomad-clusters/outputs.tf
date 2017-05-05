output "inventory_westus_public_ip" {
  value = "${module.inventory_westus_cluster.public_ip}"
}

output "inventory_westus_private_ip" {
  value = "${module.inventory_westus_cluster.private_ip}"
}

output "inventory_eastus_public_ip" {
  value = "${module.inventory_eastus_cluster.public_ip}"
}

output "inventory_eastus_private_ip" {
  value = "${module.inventory_eastus_cluster.private_ip}"
}

output "checkout_westus2_public_ip" {
  value = "${module.checkout_westus2_cluster.public_ip}"
}

output "checkout_westus2_private_ip" {
  value = "${module.checkout_westus2_cluster.private_ip}"
}

#output "configuration" {
#  value = <<CONFIGURATION
#
#CONFIGURATION
#}

