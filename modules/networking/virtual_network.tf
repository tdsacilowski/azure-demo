resource "azurerm_virtual_network" "demo_vn" {
  count               = "${length(var.location)}"
  name                = "${var.name}-vn-${count.index}"
  address_space       = ["${element(var.address_space, count.index)}"]
  location            = "${element(var.location, count.index)}"
  resource_group_name = "${var.resource_group_name}"
}
