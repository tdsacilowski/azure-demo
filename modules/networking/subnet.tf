resource "azurerm_subnet" "demo_pub_subnet" {
  count                = "${length(var.location)}"
  name                 = "${var.name}-pub-subnet-${count.index}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${element(azurerm_virtual_network.demo_vn.*.name, count.index)}"
  address_prefix       = "${element(var.address_prefix, count.index)}"
}
