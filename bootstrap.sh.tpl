#!/bin/bash
set -x

# Get dependencies
sudo apt-get update -qq && sudo apt-get install -y -qq libssl-dev libffi-dev python-dev build-essential curl unzip jq

# Get Azure CLI
echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get install apt-transport-https
sudo apt-get update -qq && sudo apt-get install -y -qq azure-cli

# Get Consul
sudo mkdir -p /opt/consul/data
cd /opt/consul
sudo curl -O https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_linux_amd64.zip
sudo unzip consul_0.7.5_linux_amd64.zip
sudo chmod 755 consul

# Get join IP address
az login --service-principal -u ${client_id} -p ${client_secret} --tenant ${tenant_id}
JOIN_IP=$(az network nic show --ids `az vm show --ids \`az resource list --tag environment=consul-dc-${dc} | jq '.[]?.id' | tr -d '"'\` | jq '.[]?.networkProfile.networkInterfaces | .[]?.id' | tr -d '"'` | jq '.[0]?.ipConfigurations[].privateIpAddress' | tr -d '"')

# Start Consul server/agent
sudo nohup ./consul agent -server -bind=0.0.0.0 -client=0.0.0.0 -node=${node_name} -join=$JOIN_IP -datacenter=dc-${dc} -data-dir="/opt/consul/data" -bootstrap-expect=3 &
sleep 1
