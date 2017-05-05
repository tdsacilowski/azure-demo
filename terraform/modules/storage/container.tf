resource "azurerm_storage_container" "demo_sc" {
  name                  = "${var.container_name}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.demo_sa.name}"
  container_access_type = "${var.container_access_type}"
}
