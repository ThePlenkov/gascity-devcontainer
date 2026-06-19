# acpr - ACP Runner

An abstract Rust binary that injects configuration into any ACP (Agent Client Protocol) agent through TOML configuration files.

## Features

- **Agent-agnostic**: Works with Devin, Claude, or any other ACP agent
- **Configuration-driven**: TOML + Markdown files for easy customization
- **No hardcoded values**: Completely abstract, requires explicit configuration
- **Modern Rust**: Uses latest stable Rust edition (2021) with current best practices
- **Well-tested**: Includes unit tests for core functionality
- **Modular architecture**: Clean separation of concerns with clear public interfaces

## Architecture

The project is organized into logical modules:

- **config.rs**: Configuration loading and parsing from TOML files
- **jsonrpc.rs**: JSON-RPC 2.0 protocol handling
- **modifier.rs**: JSON parameter modification logic
- **proxy.rs**: Core proxy implementation for message interception
- **lib.rs**: Public API for library usage
- **main.rs**: Binary entry point

## Usage

### As a binary:

```bash
acpr --config=path/to/config.toml
```

### As a library:

```rust
use acpr::{Config, AcpProxy};

let config = Config::from_args()?;
let proxy = AcpProxy::new(config)?;
proxy.run()?;
```

## Configuration

### TOML Config:

```toml
[agent]
command = "devin acp"

[instructions]
file = "./instructions.md"

[target]
method = "session/prompt"
field = "prompt"
```

### Instructions File (Markdown):

```markdown
# Agent Instructions

Your instructions here in markdown format...
```

## Building

```bash
cargo build --release
```

## Testing

```bash
cargo test
```

## Requirements

- Rust 1.71+ (based on dependency MSRV)
- Edition 2021
- Latest stable dependencies:
  - serde 1.0.228
  - serde_json 1.0.150
  - toml 0.8

## License

MIT