#!/bin/bash

# Docker Installation Script for Ubuntu Server
# This script installs Docker Engine and Docker Compose

set -e

echo "========================================"
echo "Docker Installation for Ubuntu Server"
echo "========================================"
echo ""

# Update system packages
echo "[1/5] Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install prerequisites
echo "[2/5] Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
echo "[3/5] Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "[4/5] Adding Docker repository..."
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Docker Compose
echo "[5/5] Installing Docker Engine and Docker Compose..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
echo ""
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo ""
echo "========================================"
echo "Installation completed successfully!"
echo "========================================"
echo ""
echo "Please run the following command to apply group changes:"
echo "  newgrp docker"
echo ""
echo "Or log out and log back in to apply the changes."
echo ""
echo "Verify installation with:"
echo "  docker --version"
echo "  docker run hello-world"
echo ""
