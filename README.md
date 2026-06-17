# Gas City Devcontainer Features

Devcontainer features for Gas City - modular, reusable components for AI agent orchestration.

## Features

- **gascity** - Core Gas City infrastructure
- **agent-devin** - Devin CLI agent integration
- **agent-claude** - Anthropic Claude agent integration
- **agent-codex** - GitHub Codex agent integration
- **rig-react** - React project rig
- **rig-python** - Python project rig

## Usage

```json
{
  "features": {
    "gastownhall/gascity:latest": {},
    "gastownhall/agent-devin:latest": {},
    "gastownhall/agent-claude:latest": {}
  }
}
```

## Development

Each feature is a separate directory with its own `feature.json` and installation script.

See [devcontainer features spec](https://code.visualstudio.com/devcontainers/creating-dev-container-features) for details.
