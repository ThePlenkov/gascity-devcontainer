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
- 📝 2026-06-18-acpx-devin-solution.md - acpx + devin integration solution
- 📝 2026-06-18-gc-acpx-devin-integration.md - Gas City + acpx + devin integration attempt
- 📝 2026-06-18-sacp-conductor-devin-solution.md - sacp-conductor + devin integration solution

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
