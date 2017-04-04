resource "azurerm_storage_container" "demo_sc" {
  count                 = "${length(var.location)}"
  name                  = "${var.container_name}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${element(azurerm_storage_account.demo_sa.*.name, count.index)}"
  container_access_type = "${var.container_access_type}"
  depends_on            = ["azurerm_storage_account.demo_sa"]
}
