#!/bin/bash
set -e

echo "Installing Devin CLI..."

# Install curl if not available
if ! command -v curl &> /dev/null; then
    apt-get update -y && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
fi

# Download and install Devin CLI directly from GitHub releases
LATEST_VERSION=$(curl -s https://api.github.com/repos/devin-ai/devin/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v2026.7.16")

echo "Downloading Devin CLI ${LATEST_VERSION}..."

# Download and extract
curl -fsSL "https://github.com/devin-ai/devin/releases/download/${LATEST_VERSION}/devin-linux-amd64.tar.gz" -o /tmp/devin.tar.gz
tar -xzf /tmp/devin.tar.gz -C /tmp/
rm /tmp/devin.tar.gz

# Install to /usr/local/bin
mv /tmp/devin /usr/local/bin/
chmod +x /usr/local/bin/devin

echo "Devin CLI installed successfully!"
