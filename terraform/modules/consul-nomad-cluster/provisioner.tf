#######################################
# Provisioners
#######################################

# Finish up configuring Consul, Nomad, and any other run-time configs
resource "null_resource" "configure_clients" {
  count      = "${var.vm_count}"
  depends_on = ["azurerm_virtual_machine.vm"]

  provisioner "remote-exec" {
    inline = ["${element(data.template_file.bootstrap.*.rendered, count.index)}"]

    connection {
      host        = "${element(azurerm_public_ip.vm_pub_ip.*.ip_address, count.index)}"
      user        = "${var.os_user_name}"
      private_key = "${file("${path.root}/../../scripts/ssh_keys/demo.pem")}"
    }
  }
}

# Copies over Nomad jobs
resource "null_resource" "nomad_jobs" {
  count      = "${var.vm_count}"
  depends_on = ["azurerm_virtual_machine.vm"]

  provisioner "file" {
    source      = "${path.root}/../../scripts/nomad_jobs"
    destination = "./"

    connection {
      host        = "${element(azurerm_public_ip.vm_pub_ip.*.ip_address, count.index)}"
      user        = "${var.os_user_name}"
      private_key = "${file("${path.root}/../../scripts/ssh_keys/demo.pem")}"
    }
  }
}
