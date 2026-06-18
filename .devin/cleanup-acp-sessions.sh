#!/bin/bash
# Clean up ACP sessions from Devin CLI history for this project only
# ACP sessions are identified by having many ACP-related mentions

SUMMARIES_DIR="$HOME/.local/share/devin/cli/summaries"
SESSIONS_DB="$HOME/.local/share/devin/cli/sessions.db"
SESSION_LOCKS_DIR="$HOME/.local/share/devin/cli/session_locks"
ACP_THRESHOLD=10  # Minimum ACP mentions to consider as ACP session
AUTO_DELETE=false  # Set to true with --auto flag
DRY_RUN=false     # Set to true with --dry-run flag
ALL_SESSIONS=false  # Set to true with --all flag to clean all project sessions (not just ACP)
NUKE=false        # Set to true with --nuke flag to completely wipe all session data

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_DELETE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --all)
            ALL_SESSIONS=true
            shift
            ;;
        --nuke)
            NUKE=true
            shift
            ;;
        *)
            echo "Usage: $0 [--auto] [--dry-run] [--all] [--nuke]"
            echo "  --auto     Delete without confirmation"
            echo "  --dry-run  Show what would be deleted without deleting"
            echo "  --all      Clean all project sessions (not just ACP)"
            echo "  --nuke     Completely wipe all session data (database + files)"
            exit 1
            ;;
    esac
done

# Nuke mode: completely wipe all session data
if [ "$NUKE" = true ]; then
    echo "=== NUKE MODE: Complete session data wipe ==="
    
    if [ "$DRY_RUN" = true ]; then
        echo "Would delete:"
        echo "  - $SESSIONS_DB ($(du -h "$SESSIONS_DB" 2>/dev/null | cut -f1))"
        echo "  - $SESSION_LOCKS_DIR/ ($(ls "$SESSION_LOCKS_DIR" 2>/dev/null | wc -l) files)"
        echo "  - $SUMMARIES_DIR/history_*.md ($(ls "$SUMMARIES_DIR"/history_*.md 2>/dev/null | wc -l) files)"
        echo "Dry run complete - no files deleted."
        exit 0
    fi
    
    echo "Deleting session database..."
    rm -f "$SESSIONS_DB" "$SESSIONS_DB"-shm "$SESSIONS_DB"-wal
    
    echo "Deleting session locks..."
    rm -f "$SESSION_LOCKS_DIR"/*
    
    echo "Deleting session summaries..."
    rm -f "$SUMMARIES_DIR"/history_*.md
    
    echo "=== NUKE COMPLETE ==="
    echo "All session data has been wiped. Devin CLI will recreate the database on next run."
    exit 0
fi

# Get current project directory
CURRENT_PROJECT_DIR="$(pwd)"
if [ "$ALL_SESSIONS" = true ]; then
    echo "=== Project-only mode (ALL sessions): $CURRENT_PROJECT_DIR ==="
else
    echo "=== Project-only mode (ACP only): $CURRENT_PROJECT_DIR ==="
fi

cd "$SUMMARIES_DIR" || exit 1

# Find and list sessions
if [ "$ALL_SESSIONS" = true ]; then
    echo "=== Finding ALL project sessions ==="
else
    echo "=== Finding ACP sessions ==="
fi

ACP_FILES=()
while IFS= read -r -d '' file; do
    # Check if this session is from current project
    if ! grep -qi "$CURRENT_PROJECT_DIR" "$file" 2>/dev/null; then
        continue  # Skip sessions not related to current project
    fi
    
    if [ "$ALL_SESSIONS" = true ]; then
        # Include all project sessions
        ACP_FILES+=("$file")
        echo "$(basename "$file"): project session"
    else
        # Only ACP sessions
        count=$(grep -ciE "acp_command|acp_args|agent client protocol|ACP provider" "$file" 2>/dev/null || true)
        # Remove any whitespace/newlines from count
        count=$(echo "$count" | tr -d '[:space:]')
        # Ensure count is a number, default to 0 if not
        if ! [[ "$count" =~ ^[0-9]+$ ]]; then
            count=0
        fi
        if [ "$count" -ge "$ACP_THRESHOLD" ]; then
            ACP_FILES+=("$file")
            echo "$(basename "$file"): $count ACP mentions"
        fi
    fi
done < <(find . -name "history_*.md" -print0)

echo ""
if [ "$ALL_SESSIONS" = true ]; then
    echo "=== Found ${#ACP_FILES[@]} project sessions ==="
else
    echo "=== Found ${#ACP_FILES[@]} ACP sessions ==="
fi

if [ ${#ACP_FILES[@]} -eq 0 ]; then
    if [ "$ALL_SESSIONS" = true ]; then
        echo "No project sessions found."
    else
        echo "No ACP sessions found."
    fi
    exit 0
fi

# Check for dry-run mode
if [ "$DRY_RUN" = true ]; then
    echo "Dry run complete - no files would be deleted."
    exit 0
fi

# Ask for confirmation unless auto mode
if [ "$AUTO_DELETE" = false ]; then
    echo ""
    read -p "Delete these ACP sessions? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Delete the files
if [ "$ALL_SESSIONS" = true ]; then
    echo "=== Deleting project sessions ==="
else
    echo "=== Deleting ACP sessions ==="
fi
for file in "${ACP_FILES[@]}"; do
    echo "Deleting: $(basename "$file")"
    rm "$file"
done

echo ""
echo "=== Cleanup complete ==="
if [ "$ALL_SESSIONS" = true ]; then
    echo "Deleted ${#ACP_FILES[@]} project session files."
else
    echo "Deleted ${#ACP_FILES[@]} ACP session files."
fi