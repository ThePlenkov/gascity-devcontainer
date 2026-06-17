#!/bin/bash
set -e

# Gas City Devcontainer Feature Installation Script

VERSION=${VERSION:-"latest"}

echo "Installing Gas City ${VERSION}..."

# Ensure Homebrew is available (should be installed by homebrew feature)
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Ensure homebrew feature is installed first."
    exit 1
fi

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
