#######################################
# Public IP / NIC
#######################################

resource "azurerm_public_ip" "vm_pub_ip" {
  name                         = "${var.vm_name}-pub-ip"
  location                     = "${var.vm_location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "${var.env_tag}"
  }
}

resource "azurerm_network_interface" "vm_pub_nic" {
  name                = "${var.vm_name}-pub-ip-nic"
  location            = "${var.vm_location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.vm_name}-pub-ip-config"
    subnet_id                     = "${var.vm_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vm_pub_ip.id}"
  }

  tags {
    environment = "${var.env_tag}"
  }
}

#######################################
# Virtual Machine
#######################################

resource "azurerm_virtual_machine" "vm" {
  name                          = "${var.vm_name}"
  location                      = "${var.vm_location}"
  resource_group_name           = "${var.resource_group_name}"
  network_interface_ids         = ["${azurerm_network_interface.vm_pub_nic.id}"]
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_name}-osdisk"
    vhd_uri       = "${var.storage_account}${var.container_name}/${var.vm_name}-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.os_user_name}"
    admin_password = "${var.os_user_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.env_tag}"
  }

  # Update /etc/hosts with hostname set in "computer_name" above
  provisioner "remote-exec" {
    inline = ["echo \"127.0.1.1 `hostname`\" | sudo tee --append /etc/hosts > /dev/null"]

    connection {
      host     = "${azurerm_public_ip.vm_pub_ip.ip_address}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}
