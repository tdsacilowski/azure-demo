resource "azurerm_public_ip" "demo_pub_ip" {
  count                        = "${length(var.location) * var.vms_per_cluster}"
  name                         = "${var.name}-pubip-${count.index}"
  location                     = "${element(var.location, count.index)}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  #https://github.com/hashicorp/terraform/issues/6634#issuecomment-222843191
  domain_name_label = "${format("azure-demo%02d-%.8s",count.index,  uuid())}"

  lifecycle {
    ignore_changes = ["domain_name_label"]
  }

  tags {
    environment = "${var.env_tag}-${count.index % length(var.location)}"
  }
}
