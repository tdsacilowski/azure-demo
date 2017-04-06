#!/bin/bash

set -x

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

CONSUL_VERSION=0.7.5
CONSUL_TEMPLATE_VERSION=0.18.2
NOMAD_VERSION=0.5.6

#######################################
# INSTALL DEPENDENCIES
#######################################

echo "Installing dependencies..."
sudo apt -qq -y update
sudo apt install -qq -y curl unzip jq

#######################################
# CONSUL INSTALL
#######################################

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
INSTANCE_PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
# Can't pass lists via terraform template_file (https://github.com/hashicorp/terraform/issues/9488)
JOIN_WAN_QUOTED=$(echo ${join_wan} | sed 's/\([^,]*\)/"&"/g')

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$${INSTANCE_PRIVATE_IP}",
  "advertise_addr_wan": "${public_ip}",
  "bind_addr": "0.0.0.0",
  "bootstrap_expect": ${vms_per_cluster},
  "client_addr": "0.0.0.0",
  "data_dir": "/opt/consul/data",
  "datacenter": "${dc}",
  "leave_on_terminate": true,
  "node_name": "${node_name}",
  "retry_join": ["${join_ip}"],
  "retry_join_wan": [$${JOIN_WAN_QUOTED}],
  "server": true,
  "skip_leave_on_interrupt": true,
  "translate_wan_addrs": true,
  "ui": true,
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

sudo apt -qq -y update
sudo apt -qq -y install dnsmasq-base dnsmasq

echo "Configuring Dnsmasq..."

sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."

#######################################
# NOMAD INSTALL
#######################################

echo "Fetching nomad..."
cd /tmp/

curl -o nomad.zip https://releases.hashicorp.com/nomad/$${NOMAD_VERSION}/nomad_$${NOMAD_VERSION}_linux_amd64.zip

echo "Installing nomad..."
unzip nomad.zip
rm nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -pm 0600 /etc/nomad.d

# setup nomad directories
sudo mkdir -pm 0600 /opt/nomad
sudo mkdir -p /opt/nomad/data

echo "Nomad installation complete."

#######################################
# NOMAD CONFIGURATION
#######################################

sudo tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
name       = "${node_name}"
data_dir   = "/opt/nomad/data"
datacenter = "${dc}"
bind_addr  = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = ${vms_per_cluster}
}

client {
  enabled = true
}

advertise {
  http = "${public_ip}:4646"
  rpc  = "${public_ip}:4647"
  serf = "${public_ip}:4647"
}

consul {
}
EOF

sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOF
[Unit]
Description=nomad
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/nomad
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/bin/nomad agent -config=/etc/nomad.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF



#######################################
# Setup web app
#######################################
if [[ "${dc}" =~ "inventory" ]]; then
echo "Installing Nginx..."
sudo mkdir -p /var/log/nginx
sudo chmod -R 755 /var/log/nginx
sudo apt-get install -y -q nginx


sudo tee /var/www/html/index.nginx-debian.html > /dev/null << EOF
HELLO FROM ${dc} in ${location}
EOF

sudo tee /etc/consul.d/nginx.json > /dev/null << NGINX
{"service": {
  "name": "nginx",
  "tags": ["web"],
  "port": 80,
    "checks": [
      {
        "id": "GET",
        "script": "curl localhost >/dev/null 2>&1",
        "interval": "10s"
      },
      {
        "id": "HTTP-TCP",
        "name": "HTTP TCP on port 80",
        "tcp": "localhost:80",
        "interval": "10s",
        "timeout": "1s"
      },
        {
        "id": "OS service status",
        "script": "service nginx status",
        "interval": "30s"
      }]
    }
}
NGINX

fi

#######################################
# START SERVICES
#######################################

sudo systemctl enable consul.service
sudo systemctl start consul

sudo systemctl enable nomad.service
sudo systemctl start nomad

#sudo service nginx start
