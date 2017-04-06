resource "azurerm_network_interface" "demo_pub_nic" {
  count               = "${var.consul_cluster_size}"
  name                = "${var.name}-pubip-nic-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.name}-pubip-config-${count.index}"
    subnet_id                     = "${azurerm_subnet.demo_pub_subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.demo_pub_ip.*.id, count.index)}"
  }

  tags {
    environment = "${var.env_tag}"
  }
}
