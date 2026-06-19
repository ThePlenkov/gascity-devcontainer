//! acpr - ACP (Agent Client Protocol) Runner Library
//! 
//! This library provides functionality for intercepting and modifying
//! ACP JSON-RPC messages for any ACP agent.

pub mod config;
pub mod jsonrpc;
pub mod modifier;
pub mod proxy;

pub use config::{Config, ConfigError};
pub use jsonrpc::{parse_request, JsonRpcRequest};
pub use modifier::modify_prompt;
pub use proxy::{AcpProxy, run_from_args};