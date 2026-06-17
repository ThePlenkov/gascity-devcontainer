#!/bin/bash
set -e

# Claude Agent Configuration Script for Gas City

API_KEY=${APIKEY:-""}

echo "Configuring Claude as Gas City agent provider..."

# Install anthropic Python package if needed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 not found, skipping anthropic package installation"
else
    pip3 install anthropic || echo "Failed to install anthropic package"
fi

# Set up environment variable if API key provided
if [ -n "$API_KEY" ]; then
    echo "export ANTHROPIC_API_KEY=$API_KEY" >> /etc/environment
    echo "ANTHROPIC_API_KEY set in /etc/environment"
else
    echo "No API key provided. Set ANTHROPIC_API_KEY environment variable manually."
fi

# Create example city.toml configuration
mkdir -p /usr/local/share/gascity/examples
cat > /usr/local/share/gascity/examples/claude-provider.toml << 'EOF'
# Example Claude provider configuration for city.toml
[providers.claude]
base = "builtin:claude"

# Set API key via environment variable:
# export ANTHROPIC_API_KEY=your-api-key

# Or configure in city.toml (not recommended for security):
# [providers.claude.env]
# ANTHROPIC_API_KEY = "your-api-key"
EOF

echo "Claude agent provider configured successfully!"
echo "Add provider = 'claude' to your city.toml"
echo "Set ANTHROPIC_API_KEY environment variable with your API key"
