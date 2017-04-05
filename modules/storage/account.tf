resource "azurerm_storage_account" "demo_sa" {
  name                = "${format("%s%.8s", var.storage_account_name, uuid())}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "${var.account_type}"

  lifecycle {
    ignore_changes = ["name"]
  }

  tags {
    environment = "Demo"
  }
}
