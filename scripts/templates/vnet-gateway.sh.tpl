#!/bin/bash
set -xo pipefail

# Create a public IP for the Virtual Network Gateway
az network public-ip create \
--resource-group ${resource_group} \
--name ${vn_gw_pub_ip_name} \
--location ${location}

# Create a subnet for the Virtual Network Gateway
# NOTE: "-name" must remain as "GatewaySubnet"
az network vnet subnet create \
--resource-group ${resource_group} \
--vnet-name ${vn_name} \
--name GatewaySubnet \
--address-prefix ${vn_gw_address_prefix}

# Create the Virtual Network Gateway
# NOTE: this will take some time, ~30 minutes or so
az network vnet-gateway create \
--sku Basic \
--resource-group ${resource_group} \
--gateway-type Vpn \
--public-ip-address ${vn_gw_pub_ip_name} \
--vpn-type RouteBased \
--name ${vn_gw_name} \
--location ${location} \
--vnet ${vn_name}
