#######################################
# Provisioners
# 
# Separating out the provisioners from the VM resource
# in order to allow parallel creation of the VNet gateways
# since they take ~30 min each to create.
# This also allows me to keep the VM creation TF template
# generic for reuse
#######################################

# Install Azure CLI
resource "null_resource" "install_azure_cli" {
  depends_on = ["azurerm_virtual_machine.vm"]
  count      = "${var.vm_count}"

  provisioner "remote-exec" {
    inline = [
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

# Create VNet Gateways (for VPN Connections)
resource "null_resource" "create_vnet_gateway_westus" {
  depends_on = ["null_resource.install_azure_cli"]

  provisioner "remote-exec" {
    inline = ["${data.template_file.vnet_gateway_westus.rendered}"]

    connection {
      host     = "${azurerm_public_ip.vm_pub_ip.0.ip_address}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}

resource "null_resource" "create_vnet_gateway_eastus" {
  depends_on = ["null_resource.install_azure_cli"]

  provisioner "remote-exec" {
    inline = ["${data.template_file.vnet_gateway_eastus.rendered}"]

    connection {
      host     = "${azurerm_public_ip.vm_pub_ip.0.ip_address}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}

resource "null_resource" "create_vnet_gateway_westus2" {
  depends_on = ["null_resource.install_azure_cli"]

  provisioner "remote-exec" {
    inline = ["${data.template_file.vnet_gateway_westus2.rendered}"]

    connection {
      host     = "${azurerm_public_ip.vm_pub_ip.0.ip_address}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}

resource "null_resource" "create_vpn_connections" {
  depends_on = [
    "null_resource.create_vnet_gateway_westus",
    "null_resource.create_vnet_gateway_eastus",
    "null_resource.create_vnet_gateway_westus2",
  ]

  provisioner "remote-exec" {
    inline = ["${data.template_file.vpn_connections.rendered}"]

    connection {
      host     = "${azurerm_public_ip.vm_pub_ip.0.ip_address}"
      type     = "ssh"
      user     = "${var.os_user_name}"
      password = "${var.os_user_password}"
    }
  }
}
