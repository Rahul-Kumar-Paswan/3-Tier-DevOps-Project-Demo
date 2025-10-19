#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/init-sonarqube.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "===> Updating system..."
apt-get update -y

echo "===> Installing prerequisites..."
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  software-properties-common

echo "===> Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "===> Starting and enabling Docker..."
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

echo "===> Waiting for Docker daemon..."
sleep 10

echo "===> Running SonarQube container..."
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community || {
  echo "SonarQube failed to start!"
  exit 1
}

echo "===> SonarQube should be accessible on port 9000."
