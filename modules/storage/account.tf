resource "azurerm_storage_account" "demo_sa" {
  count               = "${length(var.location)}"
  name                = "${format("%s%.8s", var.storage_account_name, uuid())}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${element(var.location, count.index)}"
  account_type        = "${var.account_type}"

  lifecycle {
    ignore_changes = ["name"]
  }

  tags {
    environment = "Demo"
  }
}
