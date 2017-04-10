output "inventory_west_public_ip" {
  value = "${module.inventory_west_networking.public_ip}"
}

output "inventory_west_public_fqdn" {
  value = "${module.inventory_west_networking.public_fqdn}"
}

output "inventory_east_public_ip" {
  value = "${module.inventory_east_networking.public_ip}"
}

output "inventory_east_public_fqdn" {
  value = "${module.inventory_east_networking.public_fqdn}"
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

