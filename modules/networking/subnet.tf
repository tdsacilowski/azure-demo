resource "azurerm_subnet" "demo_pub_subnet" {
  name                 = "${var.name}-pub-subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.demo_vn.name}"
  address_prefix       = "${var.address_prefix}"
}
