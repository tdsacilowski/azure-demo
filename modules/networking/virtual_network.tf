resource "azurerm_virtual_network" "demo_vn" {
  name                = "${var.name}-vn"
  address_space       = ["${var.address_space}"]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}
