#!/bin/bash
set -e

# Gas City Validation Script

echo "Validating Gas City installation..."

# Ensure Homebrew is in PATH
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Check if gc is installed
if ! command -v gc &> /dev/null; then
    echo "Error: gc command not found. Ensure homebrew feature with packages=[\"gastownhall/gascity/gascity\"] is installed via dependsOn."
    exit 1
fi

echo "gc found at: $(which gc)"
echo "gc version: $(gc --version)"

# Run gc doctor to validate installation
echo "Running gc doctor to validate installation..."
gc doctor || {
    echo "Warning: gc doctor reported issues. This may affect Gas City functionality."
}

# Check if gc is accessible globally
if [ ! -f "/usr/local/bin/gc" ]; then
    echo "Creating symlink for gc in /usr/local/bin..."
    ln -sf /home/linuxbrew/.linuxbrew/bin/gc /usr/local/bin/gc
fi

echo "Gas City validated successfully!"
echo "Run 'gc --help' to see available commands"