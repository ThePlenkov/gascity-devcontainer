# Gas City Devcontainer Features

Modular devcontainer features for Gas City and AI development tools.

## Features

- **gascity** - Gas City AI agent orchestration platform dependencies
- **devin** - Devin CLI for AI-powered development  
- **claude** - Anthropic Claude configuration

## Usage

Add features to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "./features/gascity": {},
    "./features/devin": {},
    "./features/claude": {}
  }
}
```

## Feature Structure

Each feature follows the devcontainer specification:

```
feature-name/
├── devcontainer-feature.json    # Feature metadata
└── install.sh                  # Installation script (required name)
```

**Important:** The installation script must be named exactly `install.sh` (not `devcontainer-features-install.sh` or any other name) as per the official devcontainers specification.

## Development

Features are designed to be:
- **Independent**: No dependencies between features
- **Reusable**: Can be used in any project
- **Composable**: Mix and match as needed
- **Declarative**: JSON configuration with clear options
