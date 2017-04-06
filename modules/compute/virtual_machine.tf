data "template_file" "bootstrap" {
  count    = "${var.consul_cluster_size}"
  template = "${file("${path.module}/bootstrap.sh.tpl")}"

  vars {
    dc                  = "${var.env_tag}"
    consul_cluster_size = "${var.consul_cluster_size}"
    nomad_cluster_size  = "${var.nomad_cluster_size}"
    node_name           = "${element(var.node_name, count.index)}"
    join_ip             = "${var.public_ip[0]}"
    location            = "${var.location}"
    join_wan            = "${join(",", var.join_wan)}"
    public_ip           = "${element(var.public_ip, count.index)}"
  }
}

resource "azurerm_virtual_machine" "demo_vm" {
  count                 = "${var.consul_cluster_size}"
  name                  = "${var.name}-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(var.public_nic, count.index)}"]
  vm_size               = "Standard_A0"

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
    computer_name  = "${element(var.public_fqdn, count.index)}"
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
      host     = "${element(var.public_ip, count.index)}"
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
    }
  }
}
