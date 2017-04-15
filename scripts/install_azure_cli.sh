#!/bin/bash
set -xo pipefail

# Install Azure CLI prerequisites
sudo apt-get update -qq
sudo apt-get install -qq -y libssl-dev libffi-dev python-dev build-essential

# Install Azure CLI
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
sudo apt-get update -qq
sudo apt-get install -qq -y azure-cli
