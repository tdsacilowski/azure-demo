resource "azurerm_resource_group" "demo" {
  name     = "${var.name}"
  location = "${element(var.location, count.index)}"
}
