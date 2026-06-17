# Gas City Knowledge

Domain knowledge for Gas City (gascity) - an orchestration-builder SDK for multi-agent systems.

## Scope

This skill covers:
- Gas City configuration and setup
- Provider configuration (Devin, Claude, etc.)
- Beads storage provider options
- ACP (Agent Client Protocol) integration
- Devcontainer-specific considerations
- Common troubleshooting
- Known issues and bugs

## Provider Configuration

### Devin as ACP Provider

To configure Devin CLI as an ACP provider in Gas City:

```toml
# city.toml
[workspace]
name = "your-city"

[providers.devin]
command = "devin"
ready_delay_ms = 0
supports_acp = true
acp_command = "devin"
acp_args = ["acp"]
resume_flag = "--resume"

[[agent]]
name = "devin"
prompt_template = ".gc/system/packs/core/assets/prompts/pool-worker.md"
provider = "devin"
session = "acp"
default_sling_formula = "mol-do-work"
```

**Key fields:**
- `acp_command`: Command to run for ACP sessions
- `acp_args`: Arguments for ACP mode (typically `["acp"]`)
- `supports_acp`: Must be `true` for ACP providers
- `session`: Set to `"acp"` in agent configuration
- `resume_flag`: Flag for session resume functionality

### Testing ACP Configuration

Test Devin ACP manually:
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"1","capabilities":{}}}' | devin acp
```

Expected response: JSON-RPC response with agent capabilities and info.

## Beads Storage Provider

### Provider Options

Gas City supports multiple beads storage providers:

#### Default: `bd` Provider (Production)
- **Requires**: Dolt 2.1.0+, bd CLI 1.0.0+, flock
- **Benefits**: Durable versioned storage, production-ready
- **Setup**: Requires Dolt identity configuration
- **Use case**: Production deployments

#### File Provider (Development/Testing)
- **Requires**: No external dependencies
- **Benefits**: Simple setup, no Dolt needed
- **Setup**: Set environment variable or city.toml config
- **Use case**: Local development, testing, devcontainers

### Configuring File Provider

**Via environment:**
```bash
export GC_BEADS=file
```

**Via city.toml:**
```toml
[beads]
provider = "file"
```

### Dolt Configuration (for bd provider)

If using the default `bd` provider, configure Dolt identity:
```bash
dolt config --global --add user.name "Your Name"
dolt config --global --add user.email "you@example.com"
```

**Note**: Dolt 2.1.0+ is strictly required for Gas City due to critical fixes for GC/writer deadlock and managed Dolt compatibility.

## Devcontainer Setup

### Devin CLI Configuration

For devcontainers, mount Devin configuration from host HOME to share credentials:

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.devin,target=/home/vscode/.devin,type=bind",
    "source=${localEnv:HOME}/.config/devin,target=/home/vscode/.config/devin,type=bind",
    "source=${localEnv:HOME}/.local/share/devin,target=/home/vscode/.local/share/devin,type=bind"
  ]
}
```

This ensures:
- Devin CLI permissions are shared
- Settings persist across container rebuilds
- OAuth tokens are available in container
- Credentials work in both host and container

### Gas City Data Persistence

Mount Gas City data directories:
```json
{
  "mounts": [
    "source=${localWorkspaceFolder}/.gc,target=/workspaces/project/.gc,type=bind,consistency=cached",
    "source=${localWorkspaceFolder}/.beads,target=/workspaces/project/.beads,type=bind,consistency=cached"
  ]
}
```

## Common Troubleshooting

### City Startup Issues

**Issue**: "startup is blocked by Dolt author identity"
- **Cause**: Using bd provider without Dolt identity
- **Fix**: Configure Dolt identity OR switch to file provider

**Issue**: "dolt server could not start"
- **Cause**: Dolt server conflicts or port issues
- **Fix**: Switch to file provider for testing, or resolve Dolt server issues

**Issue**: "standalone controller already running"
- **Cause**: Previous controller process still running
- **Fix**: Kill existing gc controller processes, remove controller.lock

### Session Issues

**Issue**: Session stuck in "start-pending" state
- **Cause**: Provider configuration issues, missing dependencies
- **Fix**: Check provider configuration, verify binary availability, check supervisor logs

**Issue**: "provider catalog is missing referenced providers"
- **Cause**: Provider not registered in city.toml
- **Fix**: Add provider configuration to city.toml

### Configuration Issues

**Issue**: "unknown field" warnings in city.toml
- **Cause**: Using deprecated or incorrect field names
- **Fix**: Run `gc doctor --fix` to migrate configuration

**Issue**: Provider parity warnings
- **Cause**: Missing provider capability fields
- **Fix**: Add missing fields like `resume_flag` to provider spec

## Useful Commands

```bash
# Check city health
gc doctor

# Fix configuration issues
gc doctor --fix

# View resolved configuration
gc config show

# List agents
gc agent list

# Create session
gc session new <agent-name>

# List sessions
gc session list

# View supervisor logs
gc supervisor logs

# Check events
gc events --since 5m

# Reload configuration
gc reload
```

## Decision Framework

### When to Use File vs BD Provider

**Use file provider when:**
- Development and testing
- Devcontainer environments
- Simple setup required
- No production durability needed

**Use bd provider when:**
- Production deployments
- Versioned data storage required
- Multi-user collaboration
- Data durability and history important

### When to Configure ACP

**Use ACP transport when:**
- Provider supports ACP (like Devin CLI)
- Need JSON-RPC communication
- Editor/IDE integration
- Standardized protocol required

**Use tmux transport when:**
- Interactive terminal sessions
- Traditional agent interaction
- Provider doesn't support ACP
- Direct terminal access preferred

## Known Issues and Bugs

### Critical: Missing nudge-on-route Order (v1.2.1)
**Issue**: https://github.com/gastownhall/gascity/issues/3576

**Problem**: The `nudge-on-route.toml` file is missing from `.gc/system/packs/core/orders/` directory, completely breaking ACP task delivery.

**Symptoms**:
- ACP sessions start successfully but never receive tasks
- `gc order list` does not show `nudge-on-route` 
- Pending nudges never delivered (IN_FLIGHT=0)
- LAST NUDGE remains empty despite active sessions

**Affected Versions**: Gas City 1.2.1

**Impact**: CRITICAL - All ACP task delivery functionality broken

**Workarounds**: None currently available

**Investigation**: See DEBUG_REPORT.md for comprehensive analysis

**References**: 
- DeepWiki confirms nudge-on-route should be in core pack
- Issue affects all ACP providers, not specific to Devin CLI

## References

- [Gas City Documentation](https://docs.gascityhall.com)
- [Gas City GitHub](https://github.com/gastownhall/gascity)
- [ACP Specification](https://agentclientprotocol.com)
- [Devin CLI Documentation](https://docs.devin.ai/cli)
- [Debug Report](DEBUG_REPORT.md) - Full investigation of nudge-on-route issue
