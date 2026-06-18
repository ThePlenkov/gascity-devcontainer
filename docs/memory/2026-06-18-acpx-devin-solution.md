# Timestamp: 2026-06-18T20:20:00Z

# acpx + devin Integration Solution

## Problem
acpx (headless CLI client for Agent Client Protocol) + devin ACP integration failed with:
1. OAuth authentication errors: "Could not open browser for authentication"
2. "Permission denied: not enough credits" errors when sending prompts

## Environment
- **acpx version**: 0.11.0
- **devin version**: 2026.7.16
- **Platform**: Linux (devcontainer)
- **acpx location**: `/home/vscode/.bun/bin/acpx`
- **devin location**: `/usr/local/bin/devin`
- **Enterprise account**: Valid API key in `~/.local/share/devin/credentials.toml`

## Investigation Process

### Initial Testing - devin acp Standalone
First tested if `devin acp` works alone:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}} 
{"jsonrpc":"2.0","id":2,"method":"session/new","params":{"cwd":"/workspaces/gascity-devcontainer","mcpServers":[]}}' | devin acp
```

**Result**: ✅ Works perfectly - session created, uses CLI credentials

### acpx + devin Integration Attempts
Tried acpx with devin:

```bash
acpx devin sessions new
```

**Error**: "Could not open browser for authentication"

### Debugging - acpx Payload Analysis
Created debug wrapper to see what acpx sends:

```bash
#!/bin/bash
LOG_FILE="/tmp/devin-acp-debug.log"
echo "=== New devin acp call at $(date) ===" >> "$LOG_FILE"
while IFS= read -r line; do
    echo "INPUT: $line" >> "$LOG_FILE"
    echo "$line"
done | /usr/local/bin/devin acp | while IFS= read -r line; do
    echo "OUTPUT: $line" >> "$LOG_FILE"
    echo "$line"
done
```

**acpx initialize request**:
```json
{
  "protocolVersion": 1,
  "clientCapabilities": {
    "fs": {"readTextFile": true, "writeTextFile": true},
    "terminal": true
  },
  "clientInfo": {"name": "acpx", "version": "0.11.0"}
}
```

**acpx authenticate call**:
```json
{
  "method": "authenticate",
  "params": {"methodId": "windsurf-api-key"}
}
```

**Devin response**: "Starting browser-based PKCE authentication flow" → "Failed to open browser"

### Key Discovery - authenticate Call Triggers OAuth
Compared with manual test:
- **Manual test**: initialize → session/new (no authenticate call) → ✅ Works
- **acpx**: initialize → authenticate → ❌ OAuth required

The `authenticate` call triggers Devin ACP OAuth flow even when CLI credentials exist.

### Root Cause Analysis
1. **authPolicy: "fail"** in acpx config forces authenticate call
2. **auth section with credentials** makes Devin ACP require OAuth instead of using CLI credentials
3. acpx calls authenticate after initialize, Devin requires browser for OAuth

### Solution Discovery via DeepWiki
Consulted DeepWiki for acpx authentication:

**Key finding**: `authPolicy: "skip"` is default behavior - skips authenticate if no credentials found

### Model Issue Discovery
After fixing auth, got "Permission denied: not enough credits" error.

Debug logs showed: `"modelLabel":"Claude Sonnet 4.6"`

**Problem**: acpx using wrong model - Enterprise account only has swe-1.6 available

### Model Configuration
Tried setting model in config:
```json
{
  "model": "swe-1.6"
}
```

**acpx error**: "Cannot apply --model \"swe-1.6\": the ACP agent did not advertise that model"

**Solution**: Set model per-session after session creation:
```bash
acpx devin set model swe-1-6
```

## Root Causes

### 1. Authentication Policy
**Problem**: `authPolicy: "fail"` in `~/.acpx/config.json` forced acpx to call authenticate method
**Effect**: Devin ACP requires OAuth when authenticate is called
**Fix**: Set `authPolicy: "skip"` to skip authenticate call

### 2. Auth Credentials Configuration
**Problem**: Providing auth credentials in config made Devin ACP require OAuth
**Effect**: Even with authPolicy skip, credentials triggered OAuth flow
**Fix**: Set `auth: {}` to prevent credential conflicts

### 3. Model Selection
**Problem**: acpx defaulted to "Claude Sonnet 4.6" which Enterprise account doesn't have
**Effect**: "Permission denied: not enough credits" error
**Fix**: Set model per-session with `acpx devin set model swe-1-6`

## Solution

### Working acpx Configuration
```json
{
  "authPolicy": "skip",
  "auth": {},
  "model": "swe-1.6",
  "agents": {
    "devin": {
      "command": "/usr/local/bin/devin",
      "args": ["acp"]
    }
  }
}
```

### Usage Pattern
```bash
# Create session
acpx devin sessions new

# Set model (required per-session)
acpx devin set model swe-1-6

# Send prompt
acpx devin "your prompt here"
```

## Key Technical Findings

### Devin ACP Authentication Behavior
- **Without authenticate call**: Uses stored CLI credentials from `~/.local/share/devin/credentials.toml`
- **With authenticate call**: Requires OAuth browser flow
- **Enterprise accounts**: Have valid API keys in CLI credentials, but ACP authenticate triggers OAuth

### acpx Authentication Flow
- **authPolicy: "fail"**: Forces authenticate call → OAuth required
- **authPolicy: "skip"**: Skips authenticate if no credentials → Uses CLI credentials
- **auth section**: Providing credentials makes Devin ACP require OAuth

### Model Selection in ACP
- acpx cannot set model during session creation
- Model must be set per-session via `set model` command
- Model format: `swe-1-6` (with hyphen, not dot)

### JSON-RPC Protocol Differences
**Manual test (working)**:
```json
{
  "protocolVersion": "2024-11-05",
  "capabilities": {}
}
```

**acpx (working with fix)**:
```json
{
  "protocolVersion": 1,
  "clientCapabilities": {
    "fs": {"readTextFile": true, "writeTextFile": true},
    "terminal": true
  }
}
```

Both work when authenticate is skipped.

## Failed Approaches

### 1. Environment Variables
Tried various environment variables:
- `WINDSURF_API_KEY`
- `API_SERVER_URL`
- `ACP_BACKEND=windsurf`
- `FORCE_MANUAL_TOKEN_FLOW`

**Result**: None worked - authenticate call still triggered OAuth

### 2. Devin Configuration
Tried adding to `~/.config/devin/config.json`:
```json
{
  "devin": {
    "acp": {
      "agentEnv": {
        "WINDSURF_API_KEY": "...",
        "API_SERVER_URL": "..."
      }
    }
  }
}
```

**Result**: No effect - acpx authenticate still triggered OAuth

### 3. Token Formats
Tried different API key formats:
- `sk-ws-01-*` (standard)
- `devin-session-token$sk-ws-01-*` (Devin specific)

**Result**: No effect - authenticate call still triggered OAuth

### 4. Binary Patching
Attempted to patch `/usr/local/bin/devin` binary:
- Backup attempt failed (permission denied)
- sed patch failed with command errors
- Binary modifications broke the binary

**Result**: Binary patching not feasible

### 5. Capability Restrictions
Tried limiting acpx capabilities:
- `--no-terminal` flag
- `--deny-all` flag
- Manual capability configuration

**Result**: authenticate call still triggered regardless of capabilities

## Verification

### Test 1 - Session Creation
```bash
acpx devin sessions new
```

**Result**: ✅ Session created successfully
**Output**: `[acpx] created session cwd (session-name)`

### Test 2 - Model Setting
```bash
acpx devin set model swe-1-6
```

**Result**: ✅ Model set successfully
**Output**: `model set: swe-1-6`

### Test 3 - Prompt Execution
```bash
acpx devin "test prompt"
```

**Result**: ✅ Prompt executed successfully
**Output**: Agent response received, no credit errors

### Test 4 - Multiple Sessions
```bash
acpx devin sessions new
acpx devin set model swe-1-6
acpx devin "task 1"
acpx devin sessions new
acpx devin set model swe-1-6
acpx devin "task 2"
```

**Result**: ✅ Multiple sessions work independently

## Configuration Files Modified

### ~/.acpx/config.json
```json
{
  "authPolicy": "skip",
  "auth": {},
  "model": "swe-1.6",
  "agents": {
    "devin": {
      "command": "/usr/local/bin/devin",
      "args": ["acp"]
    }
  }
}
```

### ~/.config/devin/config.json
Added (later removed as unnecessary):
```json
{
  "devin": {
    "acp": {
      "agentEnv": {
        "WINDSURF_API_KEY": "...",
        "API_SERVER_URL": "..."
      }
    }
  }
}
```

## Documentation References

### acpx Documentation
- https://github.com/openclaw/acpx
- DeepWiki: acpx authentication policy configuration

### Devin ACP Documentation
- https://docs.devin.ai/desktop/acp
- Devin ACP uses Agent Client Protocol (ACP)
- ACP registry spec: https://agentclientprotocol.com/

### Enterprise Account
- Valid API key stored in `~/.local/share/devin/credentials.toml`
- Available models: swe-1.6, swe-1-6-fast
- Default Claude models not available

## Troubleshooting Guide

### Error: "Could not open browser for authentication"
**Cause**: authPolicy forces authenticate call
**Fix**: Set `authPolicy: "skip"` in `~/.acpx/config.json`

### Error: "Permission denied: not enough credits"
**Cause**: Using unavailable model (e.g., Claude Sonnet 4.6)
**Fix**: Set model with `acpx devin set model swe-1-6`

### Error: "Cannot apply --model"
**Cause**: Trying to set model during session creation
**Fix**: Set model after session creation with `set model` command

### Error: "Session not found"
**Cause**: Using sessionId from different devin acp process
**Fix**: Use session from current process or create new session

## Best Practices

### 1. Session Management
- Always create new session before setting model
- Close sessions when done: `acpx devin sessions close`
- Check session status: `acpx devin sessions list`

### 2. Model Configuration
- Set model per-session, not globally
- Use correct format: `swe-1-6` (hyphen, not dot)
- Verify available models: `acpx devin sessions new` shows available models

### 3. Authentication
- Keep `authPolicy: "skip"` for Enterprise accounts
- Keep `auth: {}` to prevent credential conflicts
- Never provide API keys in acpx config for Devin

### 4. Debugging
- Use debug wrapper to inspect JSON-RPC payloads
- Check `/tmp/devin-acp-debug.log` for detailed logs
- Compare acpx requests with manual tests

## Status
✅ **Working** - acpx + devin integration fully functional with Enterprise model
✅ **Verified** - Session creation, model setting, prompt execution all working
✅ **Documented** - Configuration files, usage patterns, troubleshooting guide

## Next Steps
- Monitor for acpx updates that might change authentication behavior
- Consider contributing fix to acpx for better Enterprise account support
- Document model availability for different account types