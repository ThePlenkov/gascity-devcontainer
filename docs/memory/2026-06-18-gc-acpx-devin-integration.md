# Timestamp: 2026-06-18T20:30:00Z

# gc -> acpx -> devin Integration

## Goal
Integrate Gas City to use acpx as proxy for devin ACP:
```
Gas City -> acpx --agent "devin acp" -> devin acp (ACP сервер)
```

## Configuration

### city.toml Changes
```toml
[providers.devin]
command = "acpx"
ready_delay_ms = 0
supports_acp = true
resume_flag = "--resume"
acp_command = "acpx"
acp_args = ["--agent", "devin acp"]
```

### acpx Configuration
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

## Testing Results

### acpx Standalone Test
```bash
acpx --agent "devin acp" --verbose sessions new
```

**Result**: ✅ Works
- acpx spawns devin acp as backend
- JSON-RPC handshake successful
- Session created: `flower-crime`
- Authentication skipped (authPolicy: "skip")

### Gas City Integration Test
```bash
gc sling devin "test task with acpx"
```

**Result**: ⚠️ Partial success
- Bead created: gc-8896
- New sessions created: gc-8905, gc-8906 (devin-1, devin-2)
- Sessions in "start-pending" state
- Permission issues with lock files

## Current Status

### Working
- ✅ acpx can proxy devin acp via `--agent "devin acp"`
- ✅ Gas City accepts acpx as provider
- ✅ Session creation initiated
- ✅ acpx authentication working

### Issues
- ⚠️ Permission problems with `.gc/*.lock` files
- ⚠️ Session alias conflicts
- ⚠️ Sessions stuck in "start-pending" state
- ⚠️ File permission issues preventing proper session startup

### Root Causes
1. **File permissions**: `.gc` directory has mixed ownership (root vs vscode)
2. **Lock file conflicts**: Old lock files from previous runs
3. **Alias conflicts**: Old session aliases conflicting with new sessions

## Next Steps

### Immediate
1. Fix file permissions in `.gc` directory
2. Clean up old lock files
3. Close old conflicting sessions
4. Test clean session creation

### Configuration
1. Verify acpx args are correct for Gas City ACP handshake
2. Test if additional acpx flags needed
3. Monitor session startup logs

### Verification
1. Create new task with clean environment
2. Verify session reaches active state
3. Test task execution through acpx proxy
4. Monitor end-to-end gc -> acpx -> devin flow

## Architecture

### Intended Flow
```
Gas City (sling) 
  -> acpx --agent "devin acp" 
    -> devin acp (ACP server)
      -> Devin AI (cloud agent)
```

### Current Flow
```
Gas City (sling)
  -> acpx --agent "devin acp"
    -> [Session creation initiated]
      -> [Stuck in start-pending due to permissions]
```

## Technical Details

### acpx Proxy Mode
`acpx --agent "devin acp"` works as:
- JSON-RPC client to devin acp
- Handles authentication (skipped via authPolicy)
- Manages session lifecycle
- Provides unified interface

### Gas City Provider Integration
Gas City expects:
- `command`: Binary to execute
- `acp_command`: ACP command
- `acp_args`: Arguments for ACP handshake
- `supports_acp`: ACP capability flag

Current config uses acpx as both command and ACP interface.

## References
- acpx documentation: https://github.com/openclaw/acpx
- Gas City ACP configuration: DeepWiki
- Previous acpx + devin solution: docs/memory/2026-06-18-acpx-devin-solution.md