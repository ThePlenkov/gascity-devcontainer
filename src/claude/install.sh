#!/bin/bash
set -e

# Anthropic Claude Configuration Script

API_KEY=${APIKEY:-""}

echo "Configuring Anthropic Claude..."

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

# Create example configuration
mkdir -p /usr/local/share/claude-examples
cat > /usr/local/share/claude-examples/usage.md << 'EOF'
# Anthropic Claude Usage

## Environment Variable
export ANTHROPIC_API_KEY="your-api-key-here"

## Python Example
```python
from anthropic import Anthropic
client = Anthropic(api_key=os.environ.get("ANTROPIC_API_KEY"))
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello, Claude!"}]
)
print(message.content)
```

## Node.js Example
```javascript
import Anthropic from '@anthropic-ai/sdk';
const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
```
EOF

echo "Anthropic Claude configured successfully!"
echo "Set ANTHROPIC_API_KEY environment variable with your API key"
