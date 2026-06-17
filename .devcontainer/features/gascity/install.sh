#!/bin/bash
set -e

# Gas City Installation Script

echo "Installing Gas City..."

# Ensure Homebrew is in PATH
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Check if gc is installed
if ! command -v gc &> /dev/null; then
    echo "Error: gc command not found. Ensure homebrew feature with packages=[\"gastownhall/gascity/gascity\"] is installed via dependsOn."
    exit 1
fi

echo "gc found at: $(which gc)"
echo "gc version: $(gc --version)"

# Validate installation
echo "Validating Gas City installation..."
gc doctor || {
    echo "Warning: gc doctor reported issues. This may affect Gas City functionality."
}

# Check if gc is accessible globally
if [ ! -f "/usr/local/bin/gc" ]; then
    echo "Creating symlink for gc in /usr/local/bin..."
    ln -sf /home/linuxbrew/.linuxbrew/bin/gc /usr/local/bin/gc
fi

echo "Gas City installed successfully!"
echo "Configure packs in city.toml and run 'gc start' to begin"