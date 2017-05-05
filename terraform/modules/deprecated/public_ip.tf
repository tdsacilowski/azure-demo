resource "azurerm_public_ip" "demo_pub_ip" {
  count                        = "${var.consul_cluster_size}"
  name                         = "${var.name}-pubip-${count.index}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  #https://github.com/hashicorp/terraform/issues/6634#issuecomment-222843191
  domain_name_label = "${format("%s-%02d-%.8s", var.name, count.index,  uuid())}"

  tags {
    environment = "${var.env_tag}"
  }
}
