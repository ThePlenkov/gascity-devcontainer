# Project Documentation System

## Controlled Documentation Files

### Core Project Files (Root Level)
- **README.md** - Project overview, setup, and basic usage
- **SPEC.md** - Project specifications and requirements
- **AGENTS.md** - This file - documentation system and agent rules

### Documentation Structure

#### Allowed Documentation Locations
1. **Root level** - Only core project files (README.md, SPEC.md, AGENTS.md)
2. **docs/memory/** - Memory/timestamped notes and solutions (tracked in git)
3. **docs/** - Detailed documentation (if needed)
4. **tmp/** - Temporary documentation (gitignored, for investigation/debugging)

#### File Creation Rules
- **NEVER** create .md files in root without approval
- **ALL** new documentation must follow this system
- **TEMPORARY** files go to `tmp/` directory
- **PERMANENT** documentation requires AGENTS.md update

## Documentation Categories

### 1. Core Documentation (Root)
- **README.md**: Project introduction, setup, quick start
- **SPEC.md**: Technical specifications, architecture, requirements
- **AGENTS.md**: This file - documentation system and rules

### 2. Investigation/Debug (tmp/)
- Temporary analysis files
- Debug reports
- Investigation notes
- Issue templates
- **RULE**: All files in tmp/ are gitignored and temporary

### 3. Memory/Timestamped Notes (docs/memory/)
- Investigation solutions and findings
- Debug session results
- Integration solutions
- **RULE**: Use date at START of filename: `2026-06-18-solution.md`
- **RULE**: Add full timestamp at start of file content: `# Timestamp: YYYY-MM-DDTHH:MM:SSZ`
- **RULE**: Files are tracked in git for documentation

### 4. Detailed Documentation (docs/ - if needed)
- Architecture documentation
- API documentation
- Contributing guidelines
- Advanced tutorials
- **RULE**: Create docs/ only when project complexity requires it

## File Creation Workflow

### For Temporary Work
1. Create files in `tmp/` directory
2. Use descriptive names: `DEBUG_ANALYSIS.md`, `INVESTIGATION_NOTES.md`
3. Clean up when investigation complete
4. Move valuable content to permanent documentation if needed

### For Permanent Documentation
1. Check if content fits existing categories
2. Update AGENTS.md to document new file/purpose
3. Create file in appropriate location
4. Ensure file serves clear, long-term purpose

### Before Creating Any .md File
1. **Question**: Is this temporary or permanent?
2. **Temporary**: Put in `tmp/`
3. **Permanent**: Check AGENTS.md system first
4. **Ask**: Does this fit existing documentation structure?

## Current Documentation Status

### Root Level (Controlled)
- ✅ README.md - Project overview
- ✅ SPEC.md - Project specifications  
- ✅ AGENTS.md - Documentation system

### Temporary (tmp/)
- 📋 DEBUG_REPORT.md - Gas City debug report
- 📋 ISSUE_TEMPLATE.md - GitHub issue template
- 📋 UPDATED_ISSUE.md - Issue update content
- 📋 UPDATE_COMMENT.md - GitHub comment content
- 🛠️ test-acp-agent.sh - Test ACP shell script
- 🛠️ test-acp-agent.py - Test ACP Python agent
- 🛠️ devin-acp-debug.sh - Debug wrapper for devin acp
- 🛠️ test-sacp-conductor.sh - Test sacp-conductor shell script
- 🛠️ test-sacp-standalone.py - Test sacp-conductor standalone Python
- 🛠️ test-sacp-session.py - Test sacp-conductor session handling Python
- 🛠️ sacp-wrapper.sh - Wrapper script for sacp-conductor

### Memory/Timestamped (docs/memory/)
- 📝 Multiple timestamped investigation and solution files (see directory for current contents)
- **RULE**: Use date at START of filename: `2026-06-18-solution.md`
- **RULE**: Add full timestamp at start of file content: `# Timestamp: YYYY-MM-DDTHH:MM:SSZ`
- **RULE**: Files are tracked in git for documentation
- Latest: 2026-06-18-assignment-final-findings.md - Assignment investigation final findings

### Documentation Directories
- ✅ docs/memory/ - Memory/timestamped notes (tracked in git)

## Rules Summary

1. **Root .md files**: Only README.md, SPEC.md, AGENTS.md allowed
2. **Temporary work**: Always use tmp/ directory
3. **Memory notes**: Use docs/memory/ with timestamps for investigation solutions
4. **Permanent docs**: Update AGENTS.md first, then create
5. **Cleanup**: Remove tmp/ files when investigation complete
6. **System**: All documentation must follow this structure

## Change Process

### Adding New Permanent Documentation
1. Propose change in AGENTS.md
2. Justify file purpose and location
3. Get approval
4. Create file
5. Update AGENTS.md to reflect new file

### Cleaning Up Temporary Files
1. Review tmp/ content
2. Move valuable insights to permanent docs
3. Delete obsolete temporary files
4. Document cleanup in commit message

## Agent Instructions

When working on this project:
1. **ALWAYS** check AGENTS.md before creating .md files
2. **NEVER** create root-level .md files without approval
3. **USE** tmp/ for all temporary investigation work
4. **UPDATE** AGENTS.md when adding permanent documentation
5. **CLEAN UP** tmp/ regularly

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:970c3bf2 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   bd dolt push
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->

<!-- BEGIN BEADS CODEX SETUP: generated by bd setup codex -->
## Beads Issue Tracker

Use Beads (`bd`) for durable task tracking in repositories that include it. Use the `beads` skill at `.agents/skills/beads/SKILL.md` (project install) or `~/.agents/skills/beads/SKILL.md` (global install) for Beads workflow guidance, then use the `bd` CLI for issue operations.

### Quick Reference

```bash
bd ready                # Find available work
bd show <id>            # View issue details
bd update <id> --claim  # Claim work
bd close <id>           # Complete work
bd prime                # Refresh Beads context
```

### Rules

- Use `bd` for all task tracking; do not create markdown TODO lists.
- Run `bd prime` when Beads context is missing or stale. Codex 0.129.0+ can load Beads context automatically through native hooks; use `/hooks` to inspect or toggle them.
- Keep persistent project memory in Beads via `bd remember`; do not create ad hoc memory files.

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.
<!-- END BEADS CODEX SETUP -->
