#!/bin/bash
set -xo pipefail

# East US to West US
az network vpn-connection create \
--name vpn-eastus-westus \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-eastus \
--location eastus \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-westus

# East US to West US 2
az network vpn-connection create \
--name vpn-eastus-westus2 \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-eastus \
--location eastus \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-westus2

# West US to East US
az network vpn-connection create \
--name vpn-westus-eastus \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-westus \
--location westus \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-eastus

# West US to West US 2
az network vpn-connection create \
--name vpn-westus-westus2 \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-westus \
--location westus \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-westus2

# West US 2 to East US
az network vpn-connection create \
--name vpn-westus2-eastus \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-westus2 \
--location westus2 \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-eastus

# West US 2 to West US
az network vpn-connection create \
--name vpn-westus2-westus \
--resource-group ${resource_group} \
--vnet-gateway1 ${vn_gw_name}-westus2 \
--location westus2 \
--shared-key ${vpn_shared_key} \
--vnet-gateway2 ${vn_gw_name}-westus
