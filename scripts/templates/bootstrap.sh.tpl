#!/bin/bash
set -xo pipefail

#######################################
# CONSUL CONFIGURATION
#######################################

# Get VM private ip address
INSTANCE_PRIVATE_IP=$(ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }')

# Can't pass lists via terraform template_file (https://github.com/hashicorp/terraform/issues/9488)
JOIN_WAN_QUOTED=$(echo ${join_wan} | sed 's/\([^,]*\)/"&"/g')

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${dc}",
  "node_name": "${node_name}",
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "server": true,
  "bootstrap_expect": ${consul_cluster_size},
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$${INSTANCE_PRIVATE_IP}",
  "retry_join": ["${join_ip}"],
  "retry_join_wan": [$${JOIN_WAN_QUOTED}],
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
# NOMAD CONFIGURATION
#######################################

sudo tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
region       = "global"
datacenter   = "${dc}"
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
EnvironmentFile=-/etc/sysconfig/nomad
Restart=on-failure
ExecStart=/usr/bin/nomad agent -config=/etc/nomad.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

#######################################
# Nomad Jobs & Create Prepared Query
#######################################
sudo curl -o /opt/nomad/jobs/redis.hcl -L https://raw.githubusercontent.com/tdsacilowski/azure-demo/master/scripts/nomad_jobs/redis.hcl
sudo curl -o /opt/nomad/jobs/inventory.hcl -L https://raw.githubusercontent.com/tdsacilowski/azure-demo/master/scripts/nomad_jobs/inventory.hcl
sudo curl -o /opt/nomad/jobs/checkout.hcl -L https://raw.githubusercontent.com/tdsacilowski/azure-demo/master/scripts/nomad_jobs/checkout.hcl

sudo curl -o /usr/local/bin/redis-cli-stats -L https://s3.amazonaws.com/hashicorp-consul-nomad-demo/bin/redis-cli-stats
sudo chmod +x /usr/local/bin/redis-cli-stats

#######################################
# Setup NGINX Web App
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

# sudo service nginx start
