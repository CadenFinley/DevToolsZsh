#!/bin/zsh

# Plugin system variables
PLUGINS_DIR="$DEVTOOLSZSH_BASE_DIR/plugins"
ENABLED_PLUGINS_FILE="$DEVTOOLSZSH_BASE_DIR/.enabled_plugins"
LOADED_PLUGINS=()

# Initialize enabled plugins file if it doesn't exist
if [[ ! -f "$ENABLED_PLUGINS_FILE" ]]; then
    touch "$ENABLED_PLUGINS_FILE"
fi

# Function to load a specific plugin
function load_plugin() {
    local plugin="$1"
    local plugin_path="$PLUGINS_DIR/$plugin.sh"
    
    if [[ -f "$plugin_path" ]]; then
        # Keep track of loaded plugins
        LOADED_PLUGINS+=("$plugin")
        source "$plugin_path"
        return 0
    else
        echo "Warning: Plugin '$plugin' not found at $plugin_path"
        return 1
    fi
}

# Function to load all enabled plugins
function load_plugins() {
    # Create plugins directory if it doesn't exist
    if [[ ! -d "$PLUGINS_DIR" ]]; then
        mkdir -p "$PLUGINS_DIR"
    fi
    
    # Clear the loaded plugins array
    LOADED_PLUGINS=()
    
    # Check if any plugins are enabled
    if [[ -f "$ENABLED_PLUGINS_FILE" && -s "$ENABLED_PLUGINS_FILE" ]]; then
        while IFS= read -r plugin || [[ -n "$plugin" ]]; do
            # Skip commented lines and empty lines
            if [[ "$plugin" == \#* || -z "$plugin" ]]; then
                continue
            fi
            
            load_plugin "$plugin"
        done < "$ENABLED_PLUGINS_FILE"
    fi
}

# Function to unload a plugin
function unload_plugin() {
    local plugin="$1"
    local plugin_path="$PLUGINS_DIR/$plugin.sh"
    
    if [[ -f "$plugin_path" ]]; then
        # Extract function and alias definitions from the plugin
        local plugin_functions=($(grep -E "^function [a-zA-Z0-9_]+\(\)" "$plugin_path" | sed 's/function \([a-zA-Z0-9_]*\)().*/\1/'))
        local plugin_aliases=($(grep -E "^alias [a-zA-Z0-9_]+=" "$plugin_path" | sed 's/alias \([a-zA-Z0-9_]*\)=.*/\1/'))
        
        # Unset functions defined by the plugin
        for func in "${plugin_functions[@]}"; do
            if typeset -f "$func" > /dev/null 2>&1; then
                unfunction "$func" 2>/dev/null
            fi
        done
        
        # Unset aliases defined by the plugin
        for al in "${plugin_aliases[@]}"; do
            if alias "$al" > /dev/null 2>&1; then
                unalias "$al" 2>/dev/null
            fi
        done
        
        # Remove from loaded plugins array
        LOADED_PLUGINS=("${LOADED_PLUGINS[@]:#$plugin}")
        echo "Plugin '$plugin' has been unloaded"
        return 0
    else
        echo "Warning: Plugin '$plugin' not found at $plugin_path"
        return 1
    fi
}

# Function to enable a plugin
function enable_plugin() {
    if [[ -z "$1" ]]; then
        echo "Usage: enable_plugin <plugin_name>"
        return 1
    fi
    
    local plugin="$1"
    local plugin_path="$PLUGINS_DIR/$plugin.sh"
    
    # Check if plugin exists
    if [[ ! -f "$plugin_path" ]]; then
        echo "Error: Plugin '$plugin' not found"
        return 1
    fi
    
    # Check if plugin is already enabled
    if grep -q "^$plugin$" "$ENABLED_PLUGINS_FILE" 2>/dev/null; then
        echo "Plugin '$plugin' is already enabled"
        return 0
    fi
    
    # Add plugin to enabled plugins file
    echo "$plugin" >> "$ENABLED_PLUGINS_FILE"
    
    # Load the plugin immediately
    load_plugin "$plugin"
    
    echo "Plugin '$plugin' has been enabled and loaded"
    return 0
}

# Function to disable a plugin
function disable_plugin() {
    if [[ -z "$1" ]]; then
        echo "Usage: disable_plugin <plugin_name>"
        return 1
    fi
    
    local plugin="$1"
    
    # Check if plugin is enabled
    if ! grep -q "^$plugin$" "$ENABLED_PLUGINS_FILE" 2>/dev/null; then
        echo "Plugin '$plugin' is not enabled"
        return 0
    fi
    
    # Remove plugin from enabled plugins file
    grep -v "^$plugin$" "$ENABLED_PLUGINS_FILE" > "${ENABLED_PLUGINS_FILE}.tmp"
    mv "${ENABLED_PLUGINS_FILE}.tmp" "$ENABLED_PLUGINS_FILE"
    
    # Unload the plugin immediately
    unload_plugin "$plugin"
    
    echo "Plugin '$plugin' has been disabled and unloaded"
    return 0
}

# Function to list all available plugins
function list_plugins() {
    echo "Available plugins:"
    for plugin_file in "$PLUGINS_DIR"/*.sh; do
        if [[ -f "$plugin_file" ]]; then
            plugin_name=$(basename "$plugin_file" .sh)
            if grep -q "^$plugin_name$" "$ENABLED_PLUGINS_FILE" 2>/dev/null; then
                echo "  [x] $plugin_name"
            else
                echo "  [ ] $plugin_name"
            fi
        fi
    done
}

# Load all enabled plugins
load_plugins
