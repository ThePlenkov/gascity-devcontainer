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

# Install Gas City (skipped for now - requires correct binary URL)
echo "Gas City binary installation skipped - requires correct release URL"
echo "Dependencies installed successfully"
echo "To install gc manually, visit: https://github.com/gastownhall/gascity/releases"
