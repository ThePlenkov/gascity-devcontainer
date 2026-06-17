#!/bin/bash
set -e

# Gas City Installation and Configuration Script

CONFIG_AUTO_START=${CONFIG_AUTOSTART:-false}
CONFIG_REGISTER_CITY=${CONFIG_REGISTERCITY:-false}
CONFIG_INIT_CITY=${CONFIG_INITCITY:-false}
CONFIG_CONFIGURE_DOLT=${CONFIG_CONFIGUREDOLT:-false}

BUILD_PACK_INSTALL=${BUILD_PACK_INSTALL:-false}
BUILD_PACK_URL=${BUILD_PACK_URL:-"https://github.com/gastownhall/gascity-packs"}
BUILD_PACK_BRANCH=${BUILD_PACK_BRANCH:-"main"}

echo "Installing and configuring Gas City..."

# Ensure Homebrew is in PATH
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Check if gc is installed
if ! command -v gc &> /dev/null; then
    echo "Error: gc command not found. Ensure homebrew feature with packages=[\"gastownhall/gascity/gascity\"] is installed via dependsOn."
    exit 1
fi

echo "gc found at: $(which gc)"
echo "gc version: $(gc --version)"

# Configure Dolt identity if requested
if [ "$CONFIG_CONFIGURE_DOLT" = "true" ]; then
    echo "Configuring Dolt identity..."
    dolt config --global --add user.name "Devin" || echo "Dolt config failed"
    dolt config --global --add user.email "devin@example.com" || echo "Dolt config failed"
fi

# Initialize city if requested
if [ "$CONFIG_INIT_CITY" = "true" ]; then
    echo "Initializing city..."
    gc init || echo "City initialization failed (may already exist)"
fi

# Register city if requested
if [ "$CONFIG_REGISTER_CITY" = "true" ]; then
    echo "Registering city..."
    gc register || echo "City registration failed (may already be registered)"
fi

# Auto-start supervisor if requested
if [ "$CONFIG_AUTO_START" = "true" ]; then
    echo "Starting supervisor..."
    gc supervisor start || echo "Supervisor start failed (may already be running)"
fi

# Install build pack if requested
if [ "$BUILD_PACK_INSTALL" = "true" ]; then
    echo "Installing build pack from $BUILD_PACK_URL (branch: $BUILD_PACK_BRANCH)..."
    gc pack import "$BUILD_PACK_URL" --branch "$BUILD_PACK_BRANCH" || echo "Build pack installation failed"
fi

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

echo "Gas City installed and configured successfully!"
echo "Run 'gc --help' to see available commands"