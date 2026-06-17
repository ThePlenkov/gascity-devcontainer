#!/bin/bash
set -e

echo "Installing development tools..."

# Install Devin CLI
echo "Installing Devin CLI..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/devin-ai/devin/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v2026.7.16")
echo "Downloading Devin CLI ${LATEST_VERSION}..."
curl -fsSL "https://github.com/devin-ai/devin/releases/download/${LATEST_VERSION}/devin-linux-amd64.tar.gz" -o /tmp/devin.tar.gz
tar -xzf /tmp/devin.tar.gz -C /tmp/
rm /tmp/devin.tar.gz
sudo mv /tmp/devin /usr/local/bin/
sudo chmod +x /usr/local/bin/devin
echo "Devin CLI installed successfully!"

# Install Gas City dependencies (if needed)
echo "Installing Gas City dependencies..."
sudo apt-get update
sudo apt-get install -y tmux jq git lsof socat libicu-dev || true
sudo apt-get clean

echo "All tools installed successfully!"