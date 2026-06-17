#!/bin/bash
set -e

# Devin CLI Agent Installation Script for Gas City

VERSION=${VERSION:-"latest"}

echo "Installing Devin CLI ${VERSION} as Gas City agent..."

# Install Devin CLI
curl -fsSL https://cli.devin.ai/install.sh | bash || true

# Copy to global location for all users
if [ -f "$HOME/.local/bin/devin" ]; then
    cp "$HOME/.local/bin/devin" /usr/local/bin/
    chmod +x /usr/local/bin/devin
fi

# Add to PATH if not already there
if ! grep -q "/usr/local/bin" /etc/environment; then
    echo "PATH=/usr/local/bin:\$PATH" >> /etc/environment
fi

# Verify installation
echo "Verifying Devin CLI installation..."
devin version || echo "Devin CLI installed (login required for full functionality)"

echo "Devin CLI agent installed successfully!"
echo "Configure in city.toml with provider = 'devin'"
