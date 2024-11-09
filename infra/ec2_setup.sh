#!/bin/bash

# Exit on any error
set -e

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install essential tools
echo "Installing git, make, gcc, and other build essentials..."
sudo apt install -y \
    git \
    make \
    gcc \
    build-essential \
    curl \
    wget

# Install Docker
echo "Installing Docker..."
# Remove any old versions
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install Docker prerequisites
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Docker Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Install Node.js 20.15.0 using nvm
echo "Installing Node.js 20.15.0..."
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install specific Node.js version
nvm install 20.15.0
nvm use 20.15.0
nvm alias default 20.15.0

# Install pnpm
echo "Installing pnpm..."
npm install -g pnpm

# Reload shell configuration
source ~/.bashrc

# Print versions for verification
echo "Verifying installations..."
echo "Git version: $(git --version)"
echo "Make version: $(make --version | head -n1)"
echo "GCC version: $(gcc --version | head -n1)"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
echo "Node.js version: $(node --version)"
echo "pnpm version: $(pnpm --version)"

echo "Installation complete! Please log out and log back in for group changes to take effect."
echo "You may need to restart your terminal for all changes to take effect."