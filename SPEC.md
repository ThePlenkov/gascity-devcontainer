# Gas City Devcontainer Specification

## Overview

This document specifies the architecture and design of the Gas City devcontainer feature, which provides automated installation and initialization of the Gas City AI agent orchestration platform within development containers.

## Architecture

### Component Structure

```
.devcontainer/
├── devcontainer.json           # Main devcontainer configuration
└── features/
    └── gascity/
        ├── devcontainer-feature.json  # Feature metadata and options
        ├── install.sh                 # Installation script (build-time)
        └── scripts/
            └── entrypoint.sh          # Initialization script (runtime)
```

### Design Rationale

The architecture follows a **build-time + runtime separation pattern**:

1. **Build-time (install.sh)**: Installs Gas City CLI tools and persists feature options for runtime use
2. **Runtime (entrypoint.sh)**: Reads persisted options and initializes the city when container starts

This separation is necessary because:
- Feature option (`AUTOREGISTER`) is available during build but not directly accessible to runtime entrypoint
- The workspace (containing `city.toml`) is only mounted at container startup
- `gc register` requires a mounted workspace to find `city.toml`

## Feature Options

### `autoRegister` (boolean, default: `false`)

Controls whether the city is automatically registered with the supervisor when the container starts.

**Usage in devcontainer.json:**
```json
{
  "features": {
    "./features/gascity": {
      "autoRegister": true
    }
  }
}
```

When `autoRegister=true`, the entrypoint will run `gc register .` to register the city with the supervisor. The `gc register` command automatically finds `city.toml` in the current directory and handles both new and existing cities.

## Implementation Details

### Installation Phase (install.sh)

The `install.sh` script runs during the container image build:

1. Validates that `gc` is installed via Homebrew (via `dependsOn`)
2. Creates symlink for global accessibility (`/usr/local/bin/gc`)
3. Creates symlink for dolt (`/usr/local/bin/dolt`) - installed as gascity dependency
4. Creates symlink for `bd` (beads daemon) for global accessibility (`/usr/local/bin/bd`) - installed as gascity dependency
5. Creates symlink for tmux (`/usr/local/bin/tmux`) - installed as gascity dependency
6. Copies `entrypoint.sh` to `/usr/local/share/gascity/entrypoint.sh`
7. **Persists autoRegister option** to file for runtime access:
   - `AUTOREGISTER` → `/usr/local/share/gascity/autoregister_enabled`

**Key insight:** The `autoRegister` option from `devcontainer-feature.json` is available as an environment variable during install.sh execution but not during entrypoint execution. Persisting it to a file bridges this gap.

### Initialization Phase (entrypoint.sh)

The `entrypoint.sh` script runs at container startup:

1. Reads persisted autoRegister option from file:
   ```bash
   AUTOREGISTER=$(cat /usr/local/share/gascity/autoregister_enabled)
   ```

2. Navigates to workspace directory (handles both standard and custom workspace names)

3. If `AUTOREGISTER=true`, registers city with supervisor:
   ```bash
   # Configure Dolt identity (required for gc register)
   dolt config --global --add user.name "DevContainer User"
   dolt config --global --add user.email "devcontainer@localhost"
   gc register .
   ```

**Why `gc register`:**
- Automatically finds `city.toml` in current directory
- Handles both new and existing cities
- Registers with supervisor and starts it
- Idempotent: safe to run multiple times
- Simpler than `gc init --file` for devcontainer use case

### Dependency Management

The feature depends on the custom `homebrew` feature for package installation:

```json
{
  "dependsOn": {
    "./features/homebrew": {
      "packages": ["gastownhall/gascity/gascity"]
    }
  }
}
```

This ensures:
- Homebrew is installed first
- Gas City CLI (`gc`) is installed via Homebrew
- Dependencies (dolt, beads, jq, tmux, flock) are installed automatically via Homebrew
- Correct installation order is enforced

### Data Persistence

The devcontainer configuration includes explicit mounts for Gas City data directories:

```json
"mounts": [
  "source=${localWorkspaceFolder}/.gc,target=/workspaces/gascity-devcontainer/.gc,type=bind,consistency=cached",
  "source=${localWorkspaceFolder}/.beads,target=/workspaces/gascity-devcontainer/.beads,type=bind,consistency=cached"
]
```

**Why explicit mounts:**
- `.gc/` contains city state, events, and runtime data
- `.beads/` contains Dolt database and agent interactions
- `.devin/` contains Devin CLI configuration and cache
- `.config/devin/` contains Devin CLI settings
- `consistency=cached` improves performance for database operations
- Guarantees data persistence across container rebuilds
- Separates data from code for cleaner workspace

## Usage Example

### Complete devcontainer.json

```json
{
  "name": "AI Development with Gas City",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "installOhMyZsh": true,
      "upgradePackages": true
    },
    "./features/gascity": {
      "autoRegister": true
    },
    "./features/devin": {}
  },
  "forwardPorts": [8080],
  "mounts": [
    "source=${localWorkspaceFolder}/.gc,target=/workspaces/gascity-devcontainer/.gc,type=bind,consistency=cached",
    "source=${localWorkspaceFolder}/.beads,target=/workspaces/gascity-devcontainer/.beads,type=bind,consistency=cached",
    "source=${localWorkspaceFolder}/.devin,target=/home/vscode/.devin,type=bind",
    "source=${localWorkspaceFolder}/.config/devin,target=/home/vscode/.config/devin,type=bind"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "github.copilot",
        "ms-vscode.vscode-typescript-next"
      ]
    }
  },
  "remoteUser": "vscode"
}
```

### Workflow

1. **Developer opens devcontainer**: VS Code detects `.devcontainer/devcontainer.json`
2. **Build phase**: Features are installed, `install.sh` runs, options are persisted
3. **Container starts**: Workspace is mounted, `entrypoint.sh` executes
4. **Auto-registration**: If `autoRegister=true`, `gc register .` runs
5. **City ready**: Supervisor starts, city is registered and ready for use
6. **Devin CLI available**: Devin CLI installed and ready for AI-powered development

## Enforcement SDD (Software Design Document)

### Why This Architecture Is Correct

#### 1. Separation of Concerns

- **install.sh**: Handles installation and configuration persistence (build-time)
- **entrypoint.sh**: Handles runtime initialization (container startup)
- **devcontainer-feature.json**: Declares metadata and options (declarative)

#### 2. Option Passing Strategy

**Problem:** Devcontainer feature options are not directly accessible to entrypoint scripts.

**Solution:** Persist autoRegister option to file during install.sh, read it during entrypoint.sh.

**Alternatives considered and rejected:**
- `containerEnv`: Cannot interpolate option values (warnings about undefined variables)
- Environment variables in entrypoint: Not populated by devcontainer spec
- `postCreateCommand`: Would work but mixes concerns (belongs in feature, not config)

#### 3. Gas City Command Selection

**Choice:** `gc register .` with Dolt identity configuration

**Rationale:**
- Automatically finds `city.toml` in current directory
- Handles both new and existing cities (no need to check)
- Registers with supervisor and starts it
- Idempotent (safe for re-runs)
- Simpler than `gc init --file` for devcontainer use case

**Note:** Dolt identity configuration is required before `gc register` because `gc register` does not configure Dolt automatically (unlike `gc init`). This is a manual setup step that must be performed in the entrypoint.

**Alternatives considered and rejected:**
- `gc init --file ${CONFIG} .`: Requires config path parameter, adds complexity
- Skip Dolt config: `gc register` fails without Dolt identity configuration
- Interactive `gc init`: Not suitable for automation

#### 4. Workspace Handling

**Challenge:** Workspace path varies across devcontainer implementations.

**Solution:** Check multiple common paths in entrypoint:
- `/workspaces/gascity-devcontainer` (standard)
- `/workspaces/$(basename ${PWD})` (dynamic fallback)

#### 5. Idempotency

All operations are designed to be idempotent:
- `gc register` on existing city: no-op or re-registers
- File persistence: Overwrites existing files safely

### Compliance with Devcontainer Spec

- ✅ Feature follows standard structure (`devcontainer-feature.json`, `install.sh`)
- ✅ Uses `dependsOn` for dependency management
- ✅ Uses `entrypoint` for runtime initialization (spec-compliant)
- ✅ Options are properly declared in `devcontainer-feature.json`
- ✅ No invalid properties (e.g., `onCreateCommand` in feature)

### Security Considerations

- No secrets or credentials persisted
- Dolt identity uses neutral placeholder values (DevContainer User/devcontainer@localhost)
- All operations run as container user (not root)
- No external network calls during initialization

### Performance Impact

- **Build time**: Minimal (Homebrew install + file writes)
- **Startup time**: ~2-5 seconds for `gc register` on existing city
- **Container size**: ~50MB for Gas City CLI + dependencies

## Testing Checklist

- [ ] Feature builds successfully with default options
- [ ] Feature builds successfully with autoRegister=true
- [ ] Container starts without autoRegister
- [ ] Container starts with autoRegister=true
- [ ] gc register executes correctly
- [ ] City is registered with supervisor
- [ ] Supervisor starts successfully
- [ ] Re-running container (rebuild) is idempotent
- [ ] gc status shows city as active

## Future Enhancements

### Potential Improvements

1. **Dolt Identity Configuration**: Allow user to specify identity via feature option
2. **Template Support**: Add option for `gc init --template` for new cities
3. **Health Checks**: Add validation that supervisor is running after registration
4. **Log Aggregation**: Capture supervisor logs for debugging

### Extension Points

- Additional scripts in `scripts/` directory for custom initialization
- Hook system for pre/post initialization steps
- Support for multiple cities per container

## References

- [Devcontainer Features Spec](https://github.com/devcontainers/spec)
- [Gas City Documentation](https://github.com/gastownhall/gascity)
- [DeepWiki: Gas City Initialization](https://deepwiki.ai)
- [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux)

## Version History

- **1.2.0** (2026-06-17): Add symlinks for dolt, bd (beads daemon), and tmux, use neutral Dolt identity (DevContainer User/devcontainer@localhost), remove redundant dolt dependency (already included in gascity formula), add port forwarding for supervisor API (8080), add explicit mounts for .gc and .beads data persistence, add Devin CLI feature with mounts for configuration persistence
- **1.1.0** (2026-06-17): Add autoRegister option with entrypoint, add dolt dependency, simplify .gitignore
- **1.0.0** (2026-06-17): Initial specification with install.sh + entrypoint pattern
