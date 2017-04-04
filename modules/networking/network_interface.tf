resource "azurerm_network_interface" "demo_pub_nic" {
  count               = "${length(var.location) * var.vms_per_region}"
  name                = "${var.name}-pubip-nic-${count.index}"
  location            = "${element(var.location, count.index)}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.name}-pubip-config-${count.index}"
    subnet_id                     = "${element(azurerm_subnet.demo_pub_subnet.*.id, count.index)}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.demo_pub_ip.*.id, count.index)}"
  }

  tags {
    environment = "${var.env_tag}-${count.index%length(var.location)}"
  }
}
