# Multi-Region Consul + Nomad in Azure

NOTE: Still a work in progress...

* Make sure you have Azure Resource Manager API permissions and credentials (more details on how to do this coming soon...)
* Project contains two sub-projects:
	* `base-infrastructure`: creates the Azure Resource Group, Storage Accounts, Virtual Networks/Subnets, a Bastion host, and runs a `remote-exec` on the Bastion that uses the Azure CLI to create VN gateways and VPN connections.
	* `consul-nomad-clusters`: creates the Consul/Nomad clusters across the desired regions (assumes `base-infrastructure` exists).

One caveat:
* `terraform destroy` doesn't work in this scenario because of the fact that we're building some components manually via the Azure CLI. Easiest way to tear down is to go to the Azure Portal and just delete the Resource Group, which will delete everything in the RG.

There's still a bunch of refactoring to do here...
