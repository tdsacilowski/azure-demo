#######################################
# Template for Bootstrap
#######################################

data "template_file" "bootstrap" {
  count    = "${var.vm_count}"
  template = "${file("${path.root}/../scripts/templates/bootstrap.sh.tpl")}"

  vars {
    dc_env_tag          = "${var.env_tag}"
    wan_env_tag         = "${var.wan_env_tag}"
    consul_cluster_size = "${var.vm_count}"
    nomad_cluster_size  = "${var.nomad_cluster_size}"
    node_name           = "${element(azurerm_public_ip.vm_pub_ip.*.fqdn, count.index)}"
    location            = "${element(var.vm_location, count.index)}"
  }
}
