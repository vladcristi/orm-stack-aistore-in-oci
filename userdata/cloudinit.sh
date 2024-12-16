#!/bin/bash

# Install golang and make it available adding it to PATH
wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Modify /etc/sudoers to have golang usable using sudo
sudo sed -i 's|secure_path = /sbin:/bin:/usr/sbin:/usr/bin|secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/go/bin|' /etc/sudoers


# Clone AIstore repo locally and install ais cli 
sudo yum -y install git
git clone https://github.com/NVIDIA/aistore.git
cd aistore && sudo make cli


# Install and enable docker
sudo dnf install -y dnf-utils zip unzip
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove -y runc
sudo dnf install -y docker-ce --nobest
sudo systemctl enable --now docker

# Run ais cluster in a docker container
sudo docker run -d -p 51080:51080 -e AIS_BACKEND_PROVIDERS="aws" \
 -e AWS_ACCESS_KEY_ID="${aws_access_key_id}" \
 -e AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}" \
 -e AWS_REGION="eu-frankfurt-1" \
 -e AWS_ENDPOINT_URL="https://${bucket_namespace}.compat.objectstorage.eu-frankfurt-1.oraclecloud.com" \
 -v /disk0:/ais/disk0   aistorage/cluster-minimal:latest