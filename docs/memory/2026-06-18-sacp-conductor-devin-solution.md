# Timestamp: 2026-06-18T20:47:00Z

# sacp-conductor -> devin Integration Solution

## Goal
Enable Gas City to use sacp-conductor as ACP proxy to devin acp:
```
Gas City -> sacp-conductor agent -> devin acp -> Devin AI
```

## Solution

### 1. Install sacp-conductor
```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Install sacp-conductor
cargo install sacp-conductor
```

### 2. Create Wrapper Script
`/workspaces/gascity-devcontainer/sacp-wrapper.sh`:
```bash
#!/bin/bash
exec /home/vscode/.cargo/bin/sacp-conductor agent --name devin "devin acp"
```

```bash
chmod +x /workspaces/gascity-devcontainer/sacp-wrapper.sh
```

### 3. Update Gas City Configuration
`city.toml`:
```toml
[providers.devin]
command = "/workspaces/gascity-devcontainer/sacp-wrapper.sh"
ready_delay_ms = 0
supports_acp = true
resume_flag = "--resume"
acp_command = "/workspaces/gascity-devcontainer/sacp-wrapper.sh"
acp_args = []
```

## Testing

### Standalone Test
```python
#!/usr/bin/env python3
import subprocess
import json
import time

def main():
    proc = subprocess.Popen(
        ["/home/vscode/.cargo/bin/sacp-conductor", "agent", "--name", "test-agent", "devin acp"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Initialize
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "test", "version": "1.0"}
        }
    }
    proc.stdin.write(json.dumps(init_request) + "\n")
    proc.stdin.flush()
    init_response = proc.stdout.readline()
    print("Initialize:", init_response.strip())

    # Session new
    session_request = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "session/new",
        "params": {
            "cwd": "/workspaces/gascity-devcontainer",
            "mcpServers": []
        }
    }
    proc.stdin.write(json.dumps(session_request) + "\n")
    proc.stdin.flush()

    # Read responses
    for _ in range(10):
        import select
        if select.select([proc.stdout], [], [], 2.0)[0]:
            line = proc.stdout.readline()
            if line:
                print("Response:", line.strip())
            else:
                break
        else:
            break

    proc.stdin.close()
    try:
        proc.wait(timeout=5)
    except:
        proc.kill()

if __name__ == "__main__":
    main()
```

### Gas City Test
```bash
# Start supervisor
gc supervisor run

# Create test task
gc sling devin "test sacp-conductor proxy"

# Check sessions
gc session list | grep devin
```

## Results

### Standalone Testing
✅ **Initialize:**
- sacp-conductor successfully proxies initialize to devin acp
- Devin responds with agent capabilities
- Uses CLI credentials automatically

✅ **Session/new:**
- sacp-conductor successfully proxies session/new to devin acp
- Session created: "jasper-acp-addition"
- Devin connects to MCP servers
- Session updates received (mode, model, commands)

### Gas City Integration
✅ **Session Creation:**
- Active sessions created successfully:
  - gc-9075 devin-8 (active)
  - gc-9059 devin-17 (active)
  - gc-9057 devin-14 (active)
  - gc-9046 devin-3 (active)
  - gc-9045 devin-2 (active)
  - gc-9043 devin-6 (active)
  - gc-9038 devin-9 (active)

✅ **ACP Handshake:**
- sacp-conductor handles ACP protocol correctly
- Gas City successfully communicates through sacp-conductor
- devin acp receives and processes requests

## Architecture

### Intended Flow
```
Gas City (sling)
  -> sacp-wrapper.sh
    -> sacp-conductor agent --name devin "devin acp"
      -> devin acp (ACP server)
        -> Devin AI (cloud agent)
```

### Current Flow
```
Gas City (sling)
  -> sacp-wrapper.sh
    -> sacp-conductor agent --name devin "devin acp"
      -> devin acp (ACP server)
        -> Devin AI (cloud agent)
        ✅ WORKING
```

## Technical Details

### sacp-conductor
- **Purpose:** Orchestrate SACP proxy chains
- **Command:** `sacp-conductor agent [COMPONENTS]...`
- **Role:** ACP server for clients, proxy to backend agents
- **Protocol:** Standard ACP with proxy capabilities

### Wrapper Script
- **Purpose:** Load cargo env and exec sacp-conductor
- **Why needed:** Gas City doesn't load shell environment
- **Alternative:** Add sacp-conductor to system PATH

### Gas City Provider Config
- **command:** Binary/script to execute
- **acp_command:** ACP command (same as command for sacp-conductor)
- **acp_args:** Arguments for ACP handshake (empty for sacp-conductor)
- **supports_acp:** Enable ACP capability
- **resume_flag:** Flag for session resumption

## Benefits

1. **Proxy Architecture:** sacp-conductor provides flexible proxy layer
2. **Authentication:** Devin uses CLI credentials automatically
3. **MCP Support:** Devin connects to MCP servers through sacp-conductor
4. **Extensible:** Can add additional proxies in chain if needed
5. **Standard ACP:** Uses standard ACP protocol, no custom protocol needed

## Troubleshooting

### Session stuck in start-pending
- Check supervisor logs: `tail /home/vscode/.gc/supervisor.log`
- Verify wrapper script is executable: `ls -l sacp-wrapper.sh`
- Test standalone: `echo '{"jsonrpc":"2.0"...}' | sacp-wrapper.sh`

### sacp-conductor not found
- Verify installation: `which sacp-conductor`
- Check cargo env: `source "$HOME/.cargo/env"`
- Use full path in wrapper: `/home/vscode/.cargo/bin/sacp-conductor`

### Debug logging
```bash
# Enable debug logging
sacp-conductor --debug agent "devin acp"

# Check debug log
cat ./<timestamp>.log
```

## References
- sacp-conductor: https://crates.io/crates/sacp-conductor
- SACP Documentation: https://agentclientprotocol.github.io/symposium-acp/
- Gas City ACP Configuration: DeepWiki
- Previous acpx + devin solution: docs/memory/2026-06-18-acpx-devin-solution.md