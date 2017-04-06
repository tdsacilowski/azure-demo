resource "azurerm_resource_group" "demo" {
  name     = "${var.name}"
  location = "${var.location}"
}
