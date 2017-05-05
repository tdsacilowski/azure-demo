#!/bin/bash
set -xo pipefail

# Wait for cloud-init to finish.
echo "Waiting 180 seconds for cloud-init to complete."
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo "Waiting ..."; sleep 2; done'

VAULT_VERSION=0.7.0

#######################################
# INSTALL DEPENDENCIES
#######################################

echo "Installing dependencies..."
sudo apt -qq -y update
sudo apt install -qq -y curl unzip jq

#######################################
# VAULT INSTALL
#######################################

echo "Fetching Vault..."
cd /tmp/

curl -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

echo "Installing Vault..."
unzip vault.zip
rm vault.zip
sudo chmod +x vault
sudo mv vault /usr/bin/vault
sudo mkdir -pm 0600 /etc/vault.d
echo "Vault installation complete."
