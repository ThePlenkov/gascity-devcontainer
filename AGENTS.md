# Project Documentation System

## Controlled Documentation Files

### Core Project Files (Root Level)
- **README.md** - Project overview, setup, and basic usage
- **SPEC.md** - Project specifications and requirements
- **AGENTS.md** - This file - documentation system and agent rules

### Documentation Structure

#### Allowed Documentation Locations
1. **Root level** - Only core project files (README.md, SPEC.md, AGENTS.md)
2. **docs/** - Detailed documentation (if needed)
3. **tmp/** - Temporary documentation (gitignored, for investigation/debugging)

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

### 3. Detailed Documentation (docs/ - if needed)
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
- 📋 ACP_DEBUG_ANALYSIS.md - Devin ACP investigation
- 📋 DEBUG_REPORT.md - Gas City debug report
- 📋 FINAL_DEBUG_REPORT.md - Final analysis
- 📋 ISSUE_TEMPLATE.md - GitHub issue template
- 📋 UPDATED_ISSUE.md - Issue update content
- 📋 UPDATE_COMMENT.md - GitHub comment content

### Documentation Directories
- ❌ docs/ - Not created yet (not needed for current project complexity)

## Rules Summary

1. **Root .md files**: Only README.md, SPEC.md, AGENTS.md allowed
2. **Temporary work**: Always use tmp/ directory
3. **Permanent docs**: Update AGENTS.md first, then create
4. **Cleanup**: Remove tmp/ files when investigation complete
5. **System**: All documentation must follow this structure

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
