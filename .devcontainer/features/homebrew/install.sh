#!/bin/bash
set -e

# Homebrew Installation Script for Devcontainers

echo "Installing Homebrew..."

# Install Homebrew for non-root user if not available
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew for non-root user..."
    
    # Install Linuxbrew as non-root user (vscode)
    export NONROOT_USER=vscode
    export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
    export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
    export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
    
    # Install Homebrew non-interactively
    sudo -u $NONROOT_USER /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
fi

# Add Homebrew to PATH for all users
echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:\$PATH\"" >> /etc/profile.d/homebrew.sh
chmod +x /etc/profile.d/homebrew.sh

# Set HOME for non-root user
export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
export PATH="$HOMEBREW_PREFIX/bin:$PATH"

echo "Homebrew installed successfully!"
echo "Run 'eval \$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' to enable in your shell"