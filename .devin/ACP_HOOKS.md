# ACP Session Cleanup Hooks

## Overview
This project includes automatic cleanup of Devin sessions to prevent session history clutter. The hook can clean either ACP-only sessions or all project sessions, depending on configuration.

## Files

### `.devin/hooks.v1.json`
Devin CLI hook configuration that automatically cleans up all project sessions when a session ends.

### `.devin/cleanup-acp-sessions.sh`
Standalone cleanup script that identifies and removes sessions related to this project. Supports both ACP-only and full project cleanup modes via the `--all` flag. It works independently without requiring any global scripts or dependencies.

## How It Works

1. **Automatic Cleanup**: When a Devin session ends, the `SessionEnd` hook triggers
2. **Project-Scoped**: Cleans ALL sessions that reference the current project directory (not just ACP)
3. **Silent Operation**: Runs in background with `--auto --all` flags for automated cleanup

## Manual Usage

```bash
# Preview what would be deleted (safe) - ACP sessions only
.devin/cleanup-acp-sessions.sh --dry-run

# Preview what would be deleted (safe) - ALL project sessions
.devin/cleanup-acp-sessions.sh --dry-run --all

# Preview complete wipe (dangerous)
.devin/cleanup-acp-sessions.sh --dry-run --nuke

# Manual cleanup with confirmation - ACP sessions only
.devin/cleanup-acp-sessions.sh

# Manual cleanup with confirmation - ALL project sessions
.devin/cleanup-acp-sessions.sh --all

# Manual complete wipe (dangerous)
.devin/cleanup-acp-sessions.sh --nuke

# Force cleanup without confirmation - ACP sessions only
.devin/cleanup-acp-sessions.sh --auto

# Force cleanup without confirmation - ALL project sessions
.devin/cleanup-acp-sessions.sh --auto --all

# Force complete wipe (dangerous)
.devin/cleanup-acp-sessions.sh --auto --nuke
```

## ACP Session Detection

Sessions are identified as ACP sessions if they contain 10+ mentions of:
- `acp_command`
- `acp_args`
- `agent client protocol`
- `ACP provider`

## Script Features

- **Project-scoped**: Only cleans sessions that reference the current project directory
- **Flexible modes**: 
  - ACP-only cleanup (default)
  - Full project cleanup (`--all` flag)
  - Complete data wipe (`--nuke` flag - dangerous!)
- **Standalone**: Works independently without requiring global scripts or external dependencies
- **Safe**: Requires confirmation by default (unless `--auto` is used)
- **Preview**: Supports `--dry-run` mode for previewing deletions
- **Database aware**: The `--nuke` mode also clears the SQLite database for complete cleanup

## Benefits

- **Clean History**: Prevents project sessions from cluttering your session list
- **Project-Scoped**: Only affects sessions related to this project
- **Automatic**: No manual intervention required
- **Team-Friendly**: Configuration is committed to the project repository
- **Flexible**: Choose between ACP-only or full project cleanup based on your needs

## Troubleshooting

If sessions are not being cleaned:
1. Check that Devin CLI is using the project's `.devin/hooks.v1.json`
2. Verify the hook script is executable: `chmod +x .devin/cleanup-acp-sessions.sh`
3. Test manually: `.devin/cleanup-acp-sessions.sh --dry-run`
4. Check Devin CLI hook loading: run `/hooks` command in a Devin session