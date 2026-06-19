//! acpr - ACP (Agent Client Protocol) Runner
//! 
//! An abstract Rust binary that injects configuration into any ACP agent
//! through TOML configuration files.

mod config;
mod jsonrpc;
mod modifier;
mod proxy;

use proxy::run_from_args;

fn main() {
    if let Err(e) = run_from_args() {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}