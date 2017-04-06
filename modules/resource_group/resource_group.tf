resource "azurerm_resource_group" "demo" {
  name     = "${var.name}"
  location = "${var.location}"
}

resource "azurerm_network_security_group" "demo-west" {
  name                = "consul-west"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}

resource "azurerm_network_security_group" "demo-east" {
  name                = "consul-west"
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}

resource "azurerm_network_security_rule" "consul-west-inbound" {
  name                        = "consul-west-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.demo.name}"
  network_security_group_name = "${azurerm_network_security_group.demo-west.name}"
}

resource "azurerm_network_security_rule" "consul-east" {
  name                        = "consul-east-inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.demo.name}"
  network_security_group_name = "${azurerm_network_security_group.demo-east.name}"
}
