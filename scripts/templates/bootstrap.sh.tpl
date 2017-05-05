#!/bin/bash
set -xo pipefail

#######################################
# CONSUL CONFIGURATION
#######################################

# Get VM private ip address
INSTANCE_PRIVATE_IP=$(ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }')

JOIN_IP=$(az network nic list --query "[?tags.environment != null] | [?tags.environment == '${dc_env_tag}'].ipConfigurations[0].privateIpAddress | join(', ', @)")
JOIN_WAN=$(echo `az network nic list --query "[?tags.environment != null] | [?contains(tags.environment, '${wan_env_tag}')].ipConfigurations[].privateIpAddress"`)

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${dc_env_tag}",
  "node_name": "${node_name}",
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "server": true,
  "bootstrap_expect": ${consul_cluster_size},
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$${INSTANCE_PRIVATE_IP}",
  "retry_join": [ $${JOIN_IP} ],
  "retry_join_wan": $${JOIN_WAN},
  "ui": true,
  "leave_on_terminate": true,
  "skip_leave_on_interrupt": true
}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=consul
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
Restart=on-failure
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

#######################################
# VAULT CONFIGURATION
#######################################

sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
cluster_name = "${dc_env_tag}"

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui=true
EOF

sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=vault
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/vault server -config=/etc/vault.d
Restart=on-failure
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

#######################################
# NOMAD CONFIGURATION
#######################################

sudo tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
region       = "global"
datacenter   = "${dc_env_tag}"
name         = "${node_name}"
data_dir     = "/opt/nomad/data"
log_level    = "DEBUG"
enable_debug = true

server {
  enabled          = true
  bootstrap_expect = ${nomad_cluster_size}
}

client {
  enabled = true
  options {
    "driver.raw_exec.enable" = "1"
  }
}

bind_addr  = "0.0.0.0"

addresses {
  rpc  = "$${INSTANCE_PRIVATE_IP}"
  serf = "$${INSTANCE_PRIVATE_IP}"
}

advertise {
  http = "$${INSTANCE_PRIVATE_IP}:4646"
  rpc  = "$${INSTANCE_PRIVATE_IP}:4647"
  serf = "$${INSTANCE_PRIVATE_IP}:4648"
}
EOF

sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOF
[Unit]
Description=nomad
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/nomad agent -config=/etc/nomad.d
Restart=on-failure
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

#######################################
# Setup NGINX Web App
#######################################

echo "Installing Nginx..."
sudo mkdir -p /var/log/nginx
sudo chmod -R 755 /var/log/nginx
sudo apt -qq -y update
sudo apt install -y -q nginx

sudo tee /var/www/html/index.nginx-debian.html > /dev/null << EOF
HELLO FROM ${dc_env_tag} in ${location}
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
        "interval": "5s"
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
        "interval": "5s"
      }]
    }
}
NGINX

#######################################
# START SERVICES
#######################################

sudo systemctl enable consul.service
sudo systemctl start consul

sudo systemctl enable vault.service
#sudo systemctl start vault

sudo systemctl enable nomad.service
#sudo systemctl start nomad

# sudo service nginx start

#######################################
# Files & Etc for Demo
#######################################

sleep 60

# Redis CLI & stats program
sudo apt install -y -q redis-tools
sudo curl -o /usr/local/bin/redis-cli-stats -L https://s3.amazonaws.com/hashicorp-consul-nomad-demo/bin/redis-cli-stats
sudo chmod +x /usr/local/bin/redis-cli-stats

# Prepared query
curl \
    -H "Content-Type: application/json" \
    -LX POST \
    -d \
'{
  "Name": "",
  "Template": {
    "Type": "name_prefix_match"
  },
  "Service": {
    "Service": "$${name.full}",
    "Failover": {
      "NearestN": 1
    },
    "OnlyPassing": true
  },
  "DNS": {
    "TTL": "2s"
  }
}' http://localhost:8500/v1/query
