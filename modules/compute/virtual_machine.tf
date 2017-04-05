data "template_file" "bootstrap" {
  count    = "${var.vms_per_cluster}"
  template = "${file("${path.module}/bootstrap.sh.tpl")}"

  vars {
    dc              = "${var.env_tag}"
    vms_per_cluster = "${var.vms_per_cluster}"
    node_name       = "${element(var.node_name, count.index)}"
    join_ip         = "${var.public_ip[0]}"
  }
}

resource "azurerm_virtual_machine" "demo_vm" {
  count               = "${var.vms_per_cluster}"
  name                = "${var.name}-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  network_interface_ids = ["${element(var.public_nic, count.index)}"]

  vm_size = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.name}-osdisk"
    vhd_uri       = "${var.storage_account}${var.container_name}/${var.name}-osdisk-${count.index}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.env_tag}"
  }

  provisioner "remote-exec" {
    inline = ["${element(data.template_file.bootstrap.*.rendered, count.index)}"]

    connection {
      #host     = "${element(var.public_fqdn, count.index)}"
      host     = "${element(var.public_ip, count.index)}"
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
    }
  }
}
