# Debug Report: Gas City ACP Task Delivery Failure

## Environment Information
- **Gas City Version**: 1.2.1
- **Platform**: Linux (WSL2)
- **Environment**: Devcontainer
- **Date**: 2026-06-17

## Problem Summary
Gas City ACP (Agent Client Protocol) sessions start successfully but fail to receive tasks. Nudge mechanism creates pending nudges but supervisor dispatcher never delivers them to ACP sessions. The `nudge-on-route` order is missing from the system, preventing automatic task delivery when beads are routed to agents.

## Symptoms

### 1. Missing nudge-on-route Order
```bash
$ gc order list
NAME                 TYPE     TRIGGER      INTERVAL/SCHED  TARGET
beads-health         exec     cooldown     30s             -
cross-rig-deps       exec     cooldown     5m              -
gate-sweep           exec     cooldown     30s             -
mol-dog-jsonl        exec     cooldown     15m             -
mol-dog-reaper       exec     cooldown     30s             -
order-tracking-sweep exec     cooldown     1m              -
orphan-sweep         exec     cooldown     5m              -
prune-branches       exec     cooldown     6h              -
spawn-storm-detect   exec     cooldown     5m              -
wisp-compact         exec     cooldown     1h             -
```

**Expected**: `nudge-on-route` should be present in the order list
**Actual**: Order is completely missing

### 2. Pending Nudges Never Delivered
```bash
$ GC_SESSION_ID=gc-521 gc nudge status
AGENT  PENDING  IN_FLIGHT  DEAD  SESSION
devin  3        0          0     devin-gc-521

pending  nudge-dd6927e238e2  due=now  source=session  Прямой нудж: ...
pending  nudge-4aaef88bbfe1  due=now  source=session  Тест с wait-idle доставкой
pending  nudge-4f2ec93fb4ee  due=now  source=session  Ручная доставка через queue режим
```

**Expected**: IN_FLIGHT should increase as nudges are delivered
**Actual**: All nudges remain pending indefinitely (IN_FLIGHT=0)

### 3. Sessions Active But No Task Delivery
```bash
$ gc session list
ID      TEMPLATE  STATE   REASON          TARGET                  TITLE  AGE  LAST ACTIVE  LAST NUDGE
gc-521  devin     active  session,config  devin                   devin  56s  -            -
```

**Expected**: LAST NUDGE should show timestamp of last delivered task
**Actual**: LAST NUDGE remains empty despite pending nudges

### 4. Devin ACP Process Running Correctly
```bash
$ ps aux | grep "devin acp"
vscode     91729  0.0  0.0   2892  1932 ?        S    20:41   0:00 sh -c devin acp
vscode     91730  1.2  0.3 161056 62140 ?        Sl   20:41   0:00 devin acp
```

**Expected**: Devin ACP process should be running
**Actual**: ✅ Devin ACP process is running correctly

## Configuration

### city.toml Configuration
```toml
[workspace]
name = "gascity-devcontainer"

[providers]
[providers.devin]
command = "devin"
acp_command = "devin"
acp_args = ["acp"]
supports_acp = true
resume_flag = "--resume"

[session.acp]
handshake_timeout = "60s"
nudge_busy_timeout = "120s"

[[agent]]
name = "devin"
prompt_template = ".gc/system/packs/core/assets/prompts/pool-worker.md"
provider = "devin"
session = "acp"
default_sling_formula = "mol-do-work"

[beads]
provider = "file"
```

### Core Pack Import
```bash
$ gc config show | grep includes
includes = ["/workspaces/gascity-devcontainer/.gc/system/packs/core", "/workspaces/gascity-devcontainer/.gc/system/packs/maintenance"]
```

**Expected**: Core pack should provide nudge-on-route order
**Actual**: Core pack is imported but nudge-on-route is missing

## Investigation Steps Taken

### 1. Manual ACP Handshake Test
```bash
$ echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"1","capabilities":{}}}' | devin acp
```

**Result**: ✅ Devin ACP responds correctly with proper JSON-RPC handshake
**Conclusion**: Devin ACP implementation is working correctly

### 2. Configuration Validation via DeepWiki
Consulted DeepWiki for ACP configuration and implemented all recommendations:
- ✅ `supports_acp = true` 
- ✅ `acp_command` and `acp_args` properly configured
- ✅ `handshake_timeout` increased to 60s
- ✅ `nudge_busy_timeout` increased to 120s
- ✅ Session transport set to "acp"

**Result**: Configuration is correct per DeepWiki guidelines
**Conclusion**: Problem is not with basic ACP configuration

### 3. Nudge Delivery Mode Testing
Tested different delivery modes:
- `--delivery=wait-idle`: Queues nudge but never delivers
- `--delivery=queue`: Queues nudge but never delivers  
- `--delivery=immediate`: Fails with connection ownership error

**Result**: All delivery modes fail to actually deliver nudges
**Conclusion**: Supervisor dispatcher is not functioning for ACP sessions

### 4. Alternative Provider Testing
Created test provider with simple `echo` command:
```toml
[providers.claude]
command = "echo"
acp_command = "echo"
acp_args = ["acp-mode"]
supports_acp = true
```

**Result**: Same issue - tasks not delivered even with simple echo provider
**Conclusion**: Problem is not specific to Devin CLI but affects ACP task delivery generally

### 5. Order Override Attempts
Attempted to enable nudge-on-route via order overrides:
```toml
[[orders.overrides]]
name = "nudge-on-route"
enabled = true
```

**Result**: Error - order "nudge-on-route" not found
**Conclusion**: Order is not available in the system at all

## Root Cause Analysis

### Primary Issue
The `nudge-on-route` order is completely missing from the system. According to DeepWiki:

> The `nudge-on-route` order is a housekeeping order included in the `core` pack of Gas City, designed to automatically nudge agents when a bead is routed to them. It is an event-driven `exec` order that triggers on `bead.updated` events and runs the `nudge-on-route.sh` script.

### Secondary Issue
Even with manual nudge commands, the supervisor dispatcher fails to deliver queued nudges to ACP sessions. This suggests:
1. The dispatcher may not recognize ACP sessions as valid delivery targets
2. There may be a version mismatch or missing components in the ACP dispatcher implementation
3. The file-based beads provider may not be compatible with the dispatcher

### Contributing Factors
1. **File-based beads provider**: Using `[beads] provider = "file"` instead of default bd provider
2. **Devcontainer environment**: Running in WSL2 devcontainer may have specific limitations
3. **Version 1.2.1**: May be a version-specific bug or missing feature

## Impact Assessment

### Severity
**HIGH** - Core functionality completely broken

### Affected Functionality
- ❌ ACP task delivery (primary use case)
- ❌ Automatic agent task routing
- ❌ Manual nudge delivery
- ❌ Devin CLI integration via ACP
- ❌ Any ACP-based provider integration

### Working Functionality
- ✅ ACP session creation and startup
- ✅ Provider process execution (Devin ACP runs correctly)
- ✅ Session management (sessions become active)
- ✅ Task creation (beads are created successfully)
- ❌ Task delivery (beads never reach agents)

## Reproduction Steps

1. Start with fresh Gas City 1.2.1 installation
2. Configure Devin as ACP provider per DeepWiki recommendations
3. Use file-based beads provider: `[beads] provider = "file"`
4. Start city: `gc start`
5. Create task: `gc sling devin "test task"`
6. Check session list: `gc session list` (shows active session)
7. Check nudge status: `GC_SESSION_ID=<id> gc nudge status` (shows pending nudges)
8. Wait for task execution: Task never executes

## Expected Behavior
1. `nudge-on-route` order should be present in `gc order list`
2. Tasks created via `gc sling` should automatically trigger nudges to routed agents
3. Manual nudges via `gc session nudge` should be delivered to active ACP sessions
4. LAST NUDGE timestamp should update when tasks are delivered
5. Agents should execute tasks and close beads

## Actual Behavior
1. `nudge-on-route` order is completely missing
2. Tasks remain in pending state indefinitely
3. Manual nudges are queued but never delivered (IN_FLIGHT=0)
4. LAST NUDGE remains empty
5. Agents never receive or execute tasks

## Workarounds Attempted

### ❌ Failed Workarounds
1. Manual order override - order not found in system
2. Different nudge delivery modes - all fail to deliver
3. Alternative providers - same issue
4. Configuration adjustments per DeepWiki - no improvement
5. City restart/reload - no change

### ⚠️ Partial Workarounds
1. Tmux transport - sessions created but face runtime-missing issues
2. Direct Devin CLI usage - works but bypasses Gas City entirely

## Recommendations

### Immediate Actions
1. **Investigate missing nudge-on-route order**: 
   - Check if this is a version 1.2.1 bug
   - Verify core pack installation integrity
   - Check if file-based beads provider affects order loading

2. **Test with default bd provider**:
   - Switch to default beads provider with Dolt
   - See if nudge-on-route appears with bd provider
   - Eliminate file provider as contributing factor

3. **Version testing**:
   - Test with different Gas City versions
   - Check if this is a regression in 1.2.1

### Long-term Solutions
1. **Fix nudge-on-route order loading** in core pack
2. **Improve error messages** when orders fail to load
3. **Add health checks** for critical orders like nudge-on-route
4. **Document ACP requirements** more clearly in official docs

## Additional Debug Information

### System Health
```bash
$ gc doctor
49 passed, 4 warnings, 1 failed
```

**Failed Check**: `v2-agent-format - unsupported PackV1 [[agent]] tables found in city.toml`

**Warnings**:
- `order-firing-current - scheduled orders are overdue`
- `jsonl-archive - local-only mode`
- `bd-split-store - legacy split store detected`
- `custom-types:city - could not read types.custom`

### Core Pack Contents
```bash
$ ls -la .gc/system/packs/core/
total 24
drwxr-xr-x 7 vscode vscode 4096 Jun 17 16:41 .
drwxr-xr-x 4 vscode vscode 4096 Jun 17 16:41 ..
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 agents
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 assets
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 formulas
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 orders
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 prompts
```

### Orders Directory
```bash
$ ls -la .gc/system/packs/core/orders/
total 20
drwxr-xr-x 2 vscode vscode 4096 Jun 17 16:41 .
drwxr-xr-x 7 vscode vscode 4096 Jun 17 16:41 ..
-rw-r--r-- 1 vscode vscode  345 Jun 17 16:41 beads-health.toml
-rw-r--r-- 1 vscode vscode  416 Jun 17 16:41 gate-sweep.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 mol-dog-jsonl.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 mol-dog-reaper.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 order-tracking-sweep.toml
```

**Critical Finding**: `nudge-on-route.toml` is **missing** from the orders directory even though core pack is supposedly loaded.

## Conclusion
This is a **critical bug** in Gas City 1.2.1 where the `nudge-on-route` order is missing from the core pack, completely breaking ACP task delivery. The issue is not specific to Devin CLI but affects any ACP provider integration. The root cause appears to be a missing or corrupted core pack installation where the essential `nudge-on-route.toml` file is absent from the orders directory.

## Next Steps
1. Create GitHub issue in gastownhall/gascity repository
2. Include this debug report as attachment
3. Tag with: bug, critical, ACP, task-delivery, nudge-on-route
4. Request immediate investigation due to severity
