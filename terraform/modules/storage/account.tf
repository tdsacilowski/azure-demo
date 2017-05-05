resource "azurerm_storage_account" "demo_sa" {
  name                = "${var.storage_account_name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  account_type        = "${var.account_type}"

  tags {
    environment = "Demo"
  }
}
