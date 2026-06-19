//! JSON parameter modification
//! 
//! This module provides functions to modify JSON-RPC parameters
//! by injecting instructions into specific fields.

use serde_json::Value;

/// Modify prompt in JSON-RPC parameters
/// 
/// This function injects instructions into the specified field of the parameters.
/// It handles the common ACP format where the target field is an array of text objects.
/// 
/// # Arguments
/// 
/// * `params` - Mutable reference to the JSON-RPC parameters
/// * `instructions` - Instructions to inject
/// * `target_field` - Name of the field to modify
pub fn modify_prompt(params: &mut Value, instructions: &str, target_field: &str) {
    if let Some(params_obj) = params.as_object_mut() {
        if let Some(field) = params_obj.get_mut(target_field) {
            if let Some(field_array) = field.as_array_mut() {
                if let Some(first_item) = field_array.get_mut(0) {
                    if let Some(text_obj) = first_item.as_object_mut() {
                        if let Some(text) = text_obj.get_mut("text") {
                            if let Some(text_str) = text.as_str() {
                                let modified = format!("{}{}", instructions, text_str);
                                *text = Value::String(modified);
                            }
                        }
                    }
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_modify_prompt() {
        let mut params = serde_json::json!({
            "prompt": [{"type": "text", "text": "original text"}]
        });
        
        modify_prompt(&mut params, "INJECTED: ", "prompt");
        
        assert_eq!(
            params["prompt"][0]["text"],
            "INJECTED: original text"
        );
    }

    #[test]
    fn test_modify_prompt_no_field() {
        let mut params = serde_json::json!({"other": "value"});
        
        // Should not panic
        modify_prompt(&mut params, "INJECTED: ", "prompt");
    }
}
