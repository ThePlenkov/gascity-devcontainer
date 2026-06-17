#!/bin/bash
set -e

# Gas City Devcontainer Feature Installation Script

VERSION=${VERSION:-"latest"}
INSTALL_DEPS=${INSTALLDEPS:-"true"}
INSTALL_DOLT=${INSTALLDOLT:-"true"}

echo "Installing Gas City ${VERSION}..."

# Install Homebrew for non-root user if not available
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew for non-root user..."
    
    # Create non-root user for Homebrew if running as root
    if [ "$(id -u)" = "0" ]; then
        # Install Linuxbrew as non-root user
        export NONROOT_USER=vscode
        export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
        export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
        export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
        export PATH="$HOMEBREW_PREFIX/bin:$PATH"
        export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH"
        export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH"
        
        # Install Homebrew non-interactively
        sudo -u $NONROOT_USER /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
    fi
fi

# Ensure Homebrew is in PATH
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Install Gas City via Homebrew
echo "Installing Gas City via Homebrew..."
if [ "$(id -u)" = "0" ]; then
    sudo -u vscode /home/linuxbrew/.linuxbrew/bin/brew install gastownhall/gascity/gascity || sudo -u vscode /home/linuxbrew/.linuxbrew/bin/brew upgrade gastownhall/gascity/gascity
else
    brew install gastownhall/gascity/gascity || brew upgrade gastownhall/gascity/gascity
fi

# Make gc available globally
if [ -f "/home/linuxbrew/.linuxbrew/bin/gc" ] && [ ! -f "/usr/local/bin/gc" ]; then
    ln -sf /home/linuxbrew/.linuxbrew/bin/gc /usr/local/bin/gc
fi

echo "Gas City installed successfully!"
echo "Run 'gc --help' to get started"
