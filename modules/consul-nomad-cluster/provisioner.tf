#######################################
# Provisioners
#######################################

# Install Consul, Nomad, Docker, & Azure CLI (these will eventually be moved to a Packer image)
resource "null_resource" "install_clients" {
  count      = "${var.vm_count}"
  depends_on = ["azurerm_virtual_machine.vm"]

  provisioner "remote-exec" {
    inline = [
      "${file("${path.root}/../scripts/install_consul.sh")}",
      "${file("${path.root}/../scripts/install_nomad.sh")}",
      "${file("${path.root}/../scripts/install_docker.sh")}",
      "${file("${path.root}/../scripts/install_azure_cli.sh")}",
      "az login -u ${var.client_id} -p ${var.client_secret} --service-principal --tenant ${var.tenant_id}",
    ]

    connection {
      host     = "${element(azurerm_public_ip.vm_pub_ip.*.ip_address, count.index)}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}

# Finish up configuring Consul, Nomad, and any other run-time configs
resource "null_resource" "configure_clients" {
  count      = "${var.vm_count}"
  depends_on = ["null_resource.install_clients"]

  provisioner "remote-exec" {
    inline = ["${element(data.template_file.bootstrap.*.rendered, count.index)}"]

    connection {
      host     = "${element(azurerm_public_ip.vm_pub_ip.*.ip_address, count.index)}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}
