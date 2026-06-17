#!/bin/bash

# Devin CLI Installation Script

echo "Installing Devin CLI..."

# Install curl if not available
if ! command -v curl &> /dev/null; then
    apt-get update -y && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
fi

# Use official install script (ignore login errors in non-interactive mode)
echo "Downloading and installing Devin CLI..."
curl -fsSL https://cli.devin.ai/install.sh | bash || true

# Copy to global location if needed
if [ -f "$HOME/.local/bin/devin" ] && [ ! -f "/usr/local/bin/devin" ]; then
    cp "$HOME/.local/bin/devin" /usr/local/bin/
    chmod +x /usr/local/bin/devin
fi

echo "Devin CLI installed successfully!"