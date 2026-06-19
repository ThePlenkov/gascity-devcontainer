//! JSON-RPC protocol handling
//! 
//! This module provides structures and parsing for JSON-RPC 2.0 messages
//! used in ACP communication.

use serde::{Deserialize, Serialize};
use serde_json::Value;

/// JSON-RPC 2.0 request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonRpcRequest {
    /// JSON-RPC version (must be "2.0")
    pub jsonrpc: String,
    /// Request identifier
    pub id: Value,
    /// Method name to invoke
    pub method: String,
    /// Method parameters
    pub params: Option<Value>,
}

/// Parse a JSON-RPC request from a string
/// 
/// # Errors
/// 
/// Returns error if the string is not valid JSON or not a valid JSON-RPC request
pub fn parse_request(input: &str) -> Result<JsonRpcRequest, ParseError> {
    serde_json::from_str(input).map_err(ParseError::JsonError)
}

/// JSON-RPC parsing errors
#[derive(Debug)]
pub enum ParseError {
    /// JSON parsing error
    JsonError(serde_json::Error),
}

impl std::fmt::Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ParseError::JsonError(e) => write!(f, "JSON parsing error: {}", e),
        }
    }
}

impl std::error::Error for ParseError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            ParseError::JsonError(e) => Some(e),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_valid_request() {
        let input = r#"{"jsonrpc":"2.0","id":1,"method":"test","params":{}}"#;
        let request = parse_request(input).unwrap();
        assert_eq!(request.method, "test");
        assert_eq!(request.jsonrpc, "2.0");
    }

    #[test]
    fn test_parse_invalid_json() {
        let input = "not json";
        assert!(parse_request(input).is_err());
    }
}
