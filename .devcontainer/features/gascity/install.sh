#!/bin/bash
set -e

# Gas City Devcontainer Feature Installation Script

VERSION=${VERSION:-"latest"}
INSTALL_DEPS=${INSTALLDEPS:-"true"}
INSTALL_DOLT=${INSTALLDOLT:-"true"}

echo "Installing Gas City ${VERSION}..."

# Install dependencies if requested
if [ "$INSTALL_DEPS" = "true" ]; then
    echo "Installing dependencies..."
    apt-get update -y
    apt-get install -y \
        curl \
        git \
        tmux \
        jq \
        lsof \
        socat
    # Try to install ICU libraries, but don't fail if not available
    apt-get install -y libicu74 || apt-get install -y libicu-dev || echo "ICU libraries not available, skipping"
    apt-get clean -y
    rm -rf /var/lib/apt/lists/*
fi

# Install Dolt if requested
if [ "$INSTALL_DOLT" = "true" ]; then
    echo "Installing Dolt..."
    curl -fsSL https://github.com/dolthub/dolt/releases/latest/download/dolt-linux-amd64.tar.gz | tar -xz
    mv dolt-linux-amd64/bin/* /usr/local/bin/
    rm -rf dolt-linux-amd64
fi

# Install Gas City binary
echo "Installing Gas City binary..."
# Get latest version from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/gastownhall/gascity/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v1.2.1")

echo "Downloading Gas City ${LATEST_VERSION}..."
curl -fsSL "https://github.com/gastownhall/gascity/releases/download/${LATEST_VERSION}/gascity_${LATEST_VERSION#v}_linux_amd64.tar.gz" -o /tmp/gascity.tar.gz
tar -xzf /tmp/gascity.tar.gz -C /tmp/
mv /tmp/gc /usr/local/bin/
rm /tmp/gascity.tar.gz

echo "Gas City installed successfully!"
echo "Run 'gc --help' to get started"
