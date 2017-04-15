#######################################
# Templates to Create VNet Gateways
#######################################

data "template_file" "vnet_gateway_westus" {
  template = "${file("${path.root}/../scripts/templates/vnet-gateway.sh.tpl")}"

  vars {
    resource_group       = "${var.resource_group_name}"
    vn_gw_pub_ip_name    = "${var.vn_gw_name}-pub-ip-westus"
    location             = "westus"
    vn_name              = "${var.vn_name_westus}"
    vn_gw_address_prefix = "${var.vn_gw_address_prefix_westus}"
    vn_gw_name           = "${var.vn_gw_name}-westus"
  }
}

data "template_file" "vnet_gateway_eastus" {
  template = "${file("${path.root}/../scripts/templates/vnet-gateway.sh.tpl")}"

  vars {
    resource_group       = "${var.resource_group_name}"
    vn_gw_pub_ip_name    = "${var.vn_gw_name}-pub-ip-eastus"
    location             = "eastus"
    vn_name              = "${var.vn_name_eastus}"
    vn_gw_address_prefix = "${var.vn_gw_address_prefix_eastus}"
    vn_gw_name           = "${var.vn_gw_name}-eastus"
  }
}

data "template_file" "vnet_gateway_westus2" {
  template = "${file("${path.root}/../scripts/templates/vnet-gateway.sh.tpl")}"

  vars {
    resource_group       = "${var.resource_group_name}"
    vn_gw_pub_ip_name    = "${var.vn_gw_name}-pub-ip-westus2"
    location             = "westus2"
    vn_name              = "${var.vn_name_westus2}"
    vn_gw_address_prefix = "${var.vn_gw_address_prefix_westus2}"
    vn_gw_name           = "${var.vn_gw_name}-westus2"
  }
}

data "template_file" "vpn_connections" {
  template = "${file("${path.root}/../scripts/templates/vpn-connection.sh.tpl")}"

  vars {
    resource_group       = "${var.resource_group_name}"
    vn_gw_name           = "${var.vn_gw_name}"
    vpn_shared_key = "${var.vpn_shared_key}"
  }
}
