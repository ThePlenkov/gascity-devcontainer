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
        socat \
        libicu74
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

# Install Gas City
echo "Installing Gas City binary..."
if [ "$VERSION" = "latest" ]; then
    GC_VERSION=$(curl -s https://api.github.com/repos/gastownhall/gascity/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
else
    GC_VERSION=$VERSION
fi

curl -fsSL https://github.com/gastownhall/gascity/releases/download/${GC_VERSION}/gc-linux-amd64.tar.gz | tar -xz
mv gc /usr/local/bin/
rm -rf gc-linux-amd64

# Verify installation
echo "Verifying Gas City installation..."
gc version

echo "Gas City ${VERSION} installed successfully!"
echo "Run 'gc init <path>' to create your first city."
