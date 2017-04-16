#######################################
# Public IP / NIC
#######################################

resource "azurerm_public_ip" "vm_pub_ip" {
  count                        = "${var.vm_count}"
  name                         = "${var.vm_name}-pub-ip-${count.index}"
  location                     = "${element(var.vm_location, count.index)}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  #https://github.com/hashicorp/terraform/issues/6634#issuecomment-222843191
  domain_name_label = "${format("%s-%02d-%.8s", var.vm_name, count.index,  uuid())}"

  tags {
    environment = "${var.env_tag}"
  }
}

resource "azurerm_network_interface" "vm_pub_nic" {
  count               = "${var.vm_count}"
  name                = "${var.vm_name}-pub-ip-nic-${count.index}"
  location            = "${element(var.vm_location, count.index)}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.vm_name}-pub-ip-config"
    subnet_id                     = "${element(var.vm_subnet_id, count.index)}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.vm_pub_ip.*.id, count.index)}"
  }

  tags {
    environment = "${var.env_tag}"
  }
}

#######################################
# Virtual Machine
#######################################

resource "azurerm_virtual_machine" "vm" {
  count                         = "${var.vm_count}"
  name                          = "${var.vm_name}-${count.index}"
  location                      = "${element(var.vm_location, count.index)}"
  resource_group_name           = "${var.resource_group_name}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm_pub_nic.*.id, count.index)}"]
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_name}-osdisk-${count.index}"
    vhd_uri       = "${var.sa_blob_endpoint}${var.container_name}/${var.vm_name}-osdisk-${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${element(azurerm_public_ip.vm_pub_ip.*.fqdn, count.index)}"
    admin_username = "${var.os_user_name}"
    admin_password = "${var.os_user_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.env_tag}"
  }

  # Update /etc/hosts with hostname set in "os_profile.computer_name" above
  provisioner "remote-exec" {
    inline = ["echo \"127.0.1.1 `hostname`\" | sudo tee --append /etc/hosts > /dev/null"]

    connection {
      host     = "${element(azurerm_public_ip.vm_pub_ip.*.ip_address, count.index)}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}
