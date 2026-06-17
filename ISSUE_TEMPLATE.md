# GitHub Issue Content for gastownhall/gascity

## Title
**[BUG] Critical: Missing nudge-on-route order breaks ACP task delivery in v1.2.1**

## Labels
- bug
- critical  
- ACP
- task-delivery
- nudge-on-route

## Body

## Problem Summary
Gas City ACP (Agent Client Protocol) sessions start successfully but fail to receive tasks. The `nudge-on-route` order is completely missing from the system, preventing automatic task delivery when beads are routed to agents.

## Severity
**CRITICAL** - Core functionality completely broken for ACP task delivery

## Environment
- **Gas City Version**: 1.2.1
- **Platform**: Linux (WSL2)
- **Environment**: Devcontainer
- **Beads Provider**: file

## Root Cause
The `nudge-on-route.toml` file is **missing** from `.gc/system/packs/core/orders/` directory even though the core pack is supposedly loaded. This order is essential for ACP task delivery as it automatically nudges agents when beads are routed to them.

## Evidence

### Missing Order File
```bash
$ ls -la .gc/system/packs/core/orders/
total 20
-rw-r--r-- 1 vscode vscode  345 Jun 17 16:41 beads-health.toml
-rw-r--r-- 1 vscode vscode  416 Jun 17 16:41 gate-sweep.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 mol-dog-jsonl.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 mol-dog-reaper.toml
-rw-r--r-- 1 vscode vscode  289 Jun 17 16:41 order-tracking-sweep.toml
# nudge-on-route.toml is MISSING
```

### Order Not in System
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
# nudge-on-route is completely absent
```

### Pending Nudges Never Delivered
```bash
$ GC_SESSION_ID=gc-521 gc nudge status
AGENT  PENDING  IN_FLIGHT  DEAD  SESSION
devin  3        0          0     devin-gc-521

pending  nudge-dd6927e238e2  due=now  source=session  Прямой нудж: ...
pending  nudge-4aaef88bbfe1  due=now  source=session  Тест с wait-idle доставкой
pending  nudge-4f2ec93fb4ee  due=now  source=session  Ручная доставка через queue режим
# IN_FLIGHT remains 0 - nudges never delivered
```

### Sessions Active But No Tasks
```bash
$ gc session list
ID      TEMPLATE  STATE   REASON          LAST NUDGE
gc-521  devin     active  session,config  -  # LAST NUDGE remains empty
```

## Investigation Steps Taken
1. ✅ Verified Devin ACP process runs correctly (manual handshake test successful)
2. ✅ Implemented all DeepWiki ACP configuration recommendations
3. ✅ Tested different nudge delivery modes (wait-idle, queue, immediate)
4. ✅ Tested with alternative providers (echo command) - same issue
5. ✅ Attempted manual order override - order not found in system
6. ✅ Confirmed core pack is imported in configuration

## Impact
- ❌ ACP task delivery completely broken
- ❌ Automatic agent task routing non-functional
- ❌ Manual nudge delivery fails
- ❌ Devin CLI integration via ACP non-functional
- ❌ Any ACP-based provider integration broken

## Expected Behavior
1. `nudge-on-route` order should be present in `gc order list`
2. Tasks created via `gc sling` should automatically trigger nudges
3. Manual nudges should be delivered to active ACP sessions
4. LAST NUDGE timestamp should update when tasks are delivered

## Actual Behavior
1. `nudge-on-route` order completely missing
2. Tasks remain in pending state indefinitely
3. Manual nudges queued but never delivered
4. LAST NUDGE remains empty

## Reproduction
1. Install Gas City 1.2.1 via Homebrew: `brew install gastownhall/gascity/gascity`
2. Configure city.toml with ACP provider and file beads provider
3. Start city: `gc start`
4. Check orders: `gc order list` (nudge-on-route missing)
5. Check core pack orders directory: `ls .gc/system/packs/core/orders/` (nudge-on-route.toml missing)
6. Create task: `gc sling devin "test"`
7. Check nudge status: nudges remain pending indefinitely

## Configuration Used
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

## Additional Debug Information
Full debug report with detailed investigation steps, logs, and configuration is available in the attached DEBUG_REPORT.md file.

## Workarounds
- None found that restore ACP task delivery functionality
- Tmux transport has separate issues in devcontainer environment
- Direct CLI usage bypasses Gas City entirely

## References
- DeepWiki confirms nudge-on-route should be in core pack
- ACP configuration follows DeepWiki recommendations exactly
- Issue affects all ACP providers, not specific to Devin CLI

## Priority
**HIGH** - This completely breaks ACP task delivery, which is a core functionality for modern agent integration.

## Files
- DEBUG_REPORT.md - Full investigation details and logs
