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
echo "gc version: $(gc version)"

# Check if gc is accessible globally
if [ ! -f "/usr/local/bin/gc" ]; then
    echo "Creating symlink for gc in /usr/local/bin..."
    ln -sf /home/linuxbrew/.linuxbrew/bin/gc /usr/local/bin/gc
fi

# Copy entrypoint script to a location where it can be executed
mkdir -p /usr/local/share/gascity
cp scripts/entrypoint.sh /usr/local/share/gascity/entrypoint.sh
chmod +x /usr/local/share/gascity/entrypoint.sh

# Save autoRegister option for entrypoint to use
echo "${AUTOREGISTER}" > /usr/local/share/gascity/autoregister_enabled

echo "Gas City installed successfully!"