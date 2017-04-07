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

#output "configuration" {
#  value = <<CONFIGURATION
#
#CONFIGURATION
#}

