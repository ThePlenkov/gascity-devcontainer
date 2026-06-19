//! Configuration management for acpr
//! 
//! This module handles loading and parsing TOML configuration files
//! for the ACP runner.

use serde::Deserialize;
use std::env;
use std::fs;
use std::path::PathBuf;

/// Agent configuration
#[derive(Debug, Deserialize)]
pub struct AgentConfig {
    /// Command to run the agent
    pub command: String,
}

/// Instructions configuration
#[derive(Debug, Deserialize)]
pub struct InstructionsConfig {
    /// Text instructions (inline)
    #[serde(default)]
    pub text: Option<String>,
    /// Path to instructions file (markdown)
    #[serde(default)]
    pub file: Option<String>,
}

/// Target configuration for JSON-RPC modification
#[derive(Debug, Deserialize)]
pub struct TargetConfig {
    /// JSON-RPC method to intercept
    #[serde(default = "default_method")]
    pub method: String,
    /// JSON field to modify
    #[serde(default = "default_field")]
    pub field: String,
}

fn default_method() -> String {
    "session/prompt".to_string()
}

fn default_field() -> String {
    "prompt".to_string()
}

/// Main configuration structure
#[derive(Debug, Deserialize)]
pub struct Config {
    /// Agent configuration
    pub agent: AgentConfig,
    /// Instructions configuration
    pub instructions: InstructionsConfig,
    /// Target configuration
    pub target: TargetConfig,
    /// Path to the config file (for resolving relative paths)
    #[serde(skip)]
    pub config_path: PathBuf,
}

impl Config {
    /// Load configuration from command line arguments
    /// 
    /// Supports both `--config=path` and `--config path` formats
    /// 
    /// # Errors
    /// 
    /// Returns error if config file is not found or cannot be parsed
    pub fn from_args() -> Result<Self, ConfigError> {
        let args: Vec<String> = env::args().collect();
        
        let config_path = Self::parse_config_arg(&args)
            .ok_or(ConfigError::NoConfigFile)?;
        
        let config_path_buf = PathBuf::from(&config_path);
        
        let config_content = fs::read_to_string(&config_path)
            .map_err(|e| ConfigError::ReadError(config_path.clone(), e))?;
        
        let mut config: Config = toml::from_str(&config_content)
            .map_err(|e| ConfigError::ParseError(config_path, e))?;
        
        // Set the config path for resolving relative paths
        config.config_path = config_path_buf;
        
        Ok(config)
    }
    
    /// Get instructions content from either file or text
    pub fn get_instructions(&self) -> Result<String, ConfigError> {
        if let Some(ref file) = self.instructions.file {
            // Resolve path relative to config file directory
            let config_dir = self.config_path
                .parent()
                .ok_or(ConfigError::InvalidConfigPath)?;
            
            let file_path = PathBuf::from(file);
            let resolved_path = if file_path.is_absolute() {
                file_path
            } else {
                config_dir.join(file_path)
            };
            
            fs::read_to_string(&resolved_path)
                .map_err(|e| ConfigError::InstructionsReadError(file.clone(), e))
        } else if let Some(ref text) = self.instructions.text {
            Ok(text.clone())
        } else {
            Ok(String::new())
        }
    }
    
    fn parse_config_arg(args: &[String]) -> Option<String> {
        // Try --config=path format
        if let Some(arg) = args.iter().find(|x| x.starts_with("--config=")) {
            return Some(arg.trim_start_matches("--config=").to_string());
        }
        
        // Try positional --config path format
        if let Some(idx) = args.iter().position(|x| x == "--config") {
            if idx + 1 < args.len() {
                return Some(args[idx + 1].clone());
            }
        }
        
        None
    }
}

/// Configuration errors
#[derive(Debug)]
pub enum ConfigError {
    /// No config file specified
    NoConfigFile,
    /// Error reading config file
    ReadError(String, std::io::Error),
    /// Error parsing config file
    ParseError(String, toml::de::Error),
    /// Error reading instructions file
    InstructionsReadError(String, std::io::Error),
    /// Proxy runtime error
    ProxyError(std::io::Error),
    /// Invalid config path (cannot determine parent directory)
    InvalidConfigPath,
}

impl std::fmt::Display for ConfigError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ConfigError::NoConfigFile => {
                write!(f, "No config file found. Usage: acpr --config=<config.toml>")
            }
            ConfigError::ReadError(path, e) => {
                write!(f, "Failed to read config file '{}': {}", path, e)
            }
            ConfigError::ParseError(path, e) => {
                write!(f, "Failed to parse config file '{}': {}", path, e)
            }
            ConfigError::InstructionsReadError(path, e) => {
                write!(f, "Failed to read instructions file '{}': {}", path, e)
            }
            ConfigError::ProxyError(e) => {
                write!(f, "Proxy runtime error: {}", e)
            }
            ConfigError::InvalidConfigPath => {
                write!(f, "Invalid config path: cannot determine parent directory")
            }
        }
    }
}

impl std::error::Error for ConfigError {}

impl From<std::io::Error> for ConfigError {
    fn from(error: std::io::Error) -> Self {
        ConfigError::ProxyError(error)
    }
}