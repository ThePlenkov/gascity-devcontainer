#!/bin/bash
set -e

# Gas City Installation and Validation Script

echo "Installing and validating Gas City..."

# Install Homebrew if not available
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    
    # Install Linuxbrew as non-root user (vscode)
    export NONROOT_USER=vscode
    export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
    export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
    export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
    
    # Install Homebrew non-interactively
    sudo -u $NONROOT_USER /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
    
    # Add Homebrew to PATH for all users
    echo "export PATH=\"/home/linuxbrew/.linuxbrew/bin:\$PATH\"" >> /etc/profile.d/homebrew.sh
    chmod +x /etc/profile.d/homebrew.sh
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

# Validate installation
echo "Validating Gas City installation..."
echo "gc found at: $(which gc)"
echo "gc version: $(gc --version)"

# Run gc doctor to validate installation
echo "Running gc doctor to validate installation..."
gc doctor || {
    echo "Warning: gc doctor reported issues. This may affect Gas City functionality."
}

echo "Gas City installed and validated successfully!"
echo "Run 'gc --help' to see available commands"