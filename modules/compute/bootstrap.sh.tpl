#!/bin/bash

set -x

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

CONSUL_VERSION=0.7.5
CONSUL_TEMPLATE_VERSION=0.18.2

#######################################
# INSTALL DEPENDENCIES
#######################################

echo "Installing dependencies..."
sudo apt-get -qq -y update
sudo apt-get install -qq -y libssl-dev libffi-dev python-dev build-essential curl unzip jq

#######################################
# AZURE CLI INSTALL
#######################################

echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get install apt-transport-https
sudo apt-get update -qq && sudo apt-get install -qq -y azure-cli

#######################################
# CONSUL INSTALL
#######################################

# install consul
echo "Fetching consul..."
cd /tmp/

curl -o consul.zip https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip

echo "Installing consul..."
unzip consul.zip
rm consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -pm 0600 /etc/consul.d

# setup consul directories
sudo mkdir -pm 0600 /opt/consul
sudo mkdir -p /opt/consul/data

echo "Consul installation complete."

#######################################
# CONSUL CONFIGURATION
#######################################

# Get VM private ip address
INSTANCE_PRIVATE_IP=$(ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }')

# Get join IP address
az login --service-principal -u ${client_id} -p ${client_secret} --tenant ${tenant_id}
JOIN_IP=$(az network nic show --ids `az vm show --ids \`az resource list --tag environment=${dc} | jq '.[]?.id' | tr -d '"'\` | jq '.[]?.networkProfile.networkInterfaces | .[]?.id' | tr -d '"'` | jq '.[0]?.ipConfigurations[].privateIpAddress' | tr -d '"')

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "server": true,

  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$${INSTANCE_PRIVATE_IP}",

  "node_name": "${node_name}",

  "retry_join": ["$${JOIN_IP}"],

  "datacenter": "${dc}",

  "data_dir": "/opt/consul/data",
  "ui": true,
  "leave_on_terminate": true,
  "skip_leave_on_interrupt": true,

  "bootstrap_expect": ${vms_per_cluster}
}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF

[Unit]
Description=consul
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

#######################################
# CONSUL-TEMPLATE INSTALL
#######################################

echo "Fetching consul-template..."
cd /tmp/

curl -o consul-template.zip https://releases.hashicorp.com/consul-template/$${CONSUL_TEMPLATE_VERSION}/consul-template_$${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

echo "Installing consul-template..."
unzip consul-template.zip
rm consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

echo "Consul-template installation complete."

#######################################
# DNSMASQ INSTALL
#######################################

echo "Installing Dnsmasq..."

sudo apt-get -qq -y update
sudo apt-get -qq -y install dnsmasq-base dnsmasq

echo "Configuring Dnsmasq..."

sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."

#######################################
# START SERVICES
#######################################

sudo systemctl enable consul.service
sudo systemctl start consul
