//! ACP proxy implementation
//! 
//! This module provides the core proxy logic for intercepting and modifying
//! ACP (Agent Client Protocol) JSON-RPC messages.

use crate::config::{Config, ConfigError};
use crate::jsonrpc::parse_request;
use crate::modifier::modify_prompt;
use std::io::{self, BufRead, Write};
use std::process::{Command, Stdio};
use std::thread;

/// ACP proxy that intercepts and modifies JSON-RPC messages
pub struct AcpProxy {
    config: Config,
    instructions: String,
}

impl AcpProxy {
    /// Create a new ACP proxy from configuration
    pub fn new(config: Config) -> Result<Self, ConfigError> {
        let instructions = config.get_instructions()?;
        Ok(Self { config, instructions })
    }
    
    /// Run the proxy
    /// 
    /// This starts the agent process and begins intercepting messages
    pub fn run(self) -> io::Result<()> {
        let command_parts: Vec<&str> = self.config.agent.command.split_whitespace().collect();
        
        let mut agent = Command::new(command_parts[0])
            .args(&command_parts[1..])
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::inherit())
            .spawn()?;
        
        let stdin = io::stdin();
        let mut stdout = agent.stdin.take().expect("Failed to get stdin");
        let agent_stdout = agent.stdout.take().expect("Failed to get stdout");
        
        // Spawn thread to read from agent and forward to stdout
        let reader_thread = thread::spawn(move || {
            let reader = io::BufReader::new(agent_stdout);
            for line in reader.lines() {
                if let Ok(line) = line {
                    println!("{}", line);
                }
            }
        });
        
        // Read from stdin, modify, and forward to agent
        for line in stdin.lock().lines() {
            if let Ok(line) = line {
                self.process_line(&line, &mut stdout);
            }
        }
        
        // Wait for reader thread
        reader_thread.join().ok();
        
        // Wait for agent process
        agent.wait()?;
        
        Ok(())
    }
    
    fn process_line(&self, line: &str, stdout: &mut impl Write) {
        if let Ok(mut request) = parse_request(line) {
            if request.method == self.config.target.method {
                if let Some(ref mut params) = request.params {
                    modify_prompt(params, &self.instructions, &self.config.target.field);
                    request.params = Some(params.clone());
                }
            }
            
            if let Ok(modified_json) = serde_json::to_string(&request) {
                writeln!(stdout, "{}", modified_json).ok();
            } else {
                writeln!(stdout, "{}", line).ok();
            }
        } else {
            // Forward non-JSON lines as-is
            writeln!(stdout, "{}", line).ok();
        }
    }
}

/// Run ACP proxy with configuration from command line arguments
pub fn run_from_args() -> Result<(), ConfigError> {
    let config = Config::from_args()?;
    let proxy = AcpProxy::new(config)?;
    proxy.run().map_err(ConfigError::ProxyError)?;
    Ok(())
}