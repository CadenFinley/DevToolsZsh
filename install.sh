#!/bin/bash

# Check if auto-update mode is requested
AUTO_UPDATE=false
if [[ "$1" == "--auto-update" ]]; then
    AUTO_UPDATE=true
fi

# Check if the script is being run from a remote source
if [[ "$0" == "bash" ]]; then
    # This means the script is being run via curl pipe to bash
    # Create a temporary directory and clone the repository
    TEMP_DIR=$(mktemp -d)
    echo "Creating temporary directory at $TEMP_DIR"
    
    # Clone the repository
    echo "Downloading DevToolsZsh repository..."
    git clone https://github.com/cadenfinley/DevToolsZsh.git "$TEMP_DIR" || {
        echo "Failed to download DevToolsZsh repository. Please check your internet connection and try again."
        rm -rf "$TEMP_DIR"
        exit 1
    }
    
    # Move to the cloned directory and run the local install script
    cd "$TEMP_DIR"
    SCRIPT_DIR="$TEMP_DIR"
else
    # Normal execution from a local copy
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
ENV_LOADER_PATH="$SCRIPT_DIR/functions/environment_loader.sh"
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
ENABLED_PLUGINS_FILE="$SCRIPT_DIR/.enabled_plugins"
ZSHRC_PATH="$HOME/.zshrc"
INSTALL_DIR="$HOME/.devtoolszsh"

echo "Installing DevToolsZsh custom prompt..."

# Install to user's home directory if run via curl
if [[ "$0" == "bash" ]]; then
    # Create the installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy all files to the installation directory
    echo "Copying files to $INSTALL_DIR..."
    cp -R "$TEMP_DIR"/* "$INSTALL_DIR"
    cp -R "$TEMP_DIR"/.enabled_plugins "$INSTALL_DIR" 2>/dev/null || true
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Update paths to use the installation directory
    SCRIPT_DIR="$INSTALL_DIR"
    CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
    INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
    ENV_LOADER_PATH="$SCRIPT_DIR/functions/environment_loader.sh"
    PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
    CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
    ENABLED_PLUGINS_FILE="$SCRIPT_DIR/.enabled_plugins"
fi

# Make scripts executable
chmod +x "$CUSTOM_PROMPT_PATH"
chmod +x "$INIT_SCRIPT_PATH"
chmod +x "$ENV_LOADER_PATH"
chmod +x "$PLUGIN_LOADER_PATH"
chmod +x "$CHECK_UPDATES_PATH"

# Create the enabled plugins file if it doesn't exist
if [[ ! -f "$ENABLED_PLUGINS_FILE" ]]; then
    echo "# DevToolsZsh Enabled Plugins" > "$ENABLED_PLUGINS_FILE"
    echo "# Add one plugin name per line" >> "$ENABLED_PLUGINS_FILE"
    echo "# Lines starting with # are ignored" >> "$ENABLED_PLUGINS_FILE"
    echo "Created enabled plugins file"
fi

# Check if the entries already exist in .zshrc
if grep -q "source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH" "$ZSHRC_PATH" 2>/dev/null; then
    echo "DevToolsZsh is already installed in $ZSHRC_PATH"
    
    # If auto-update is requested, add it even if DevToolsZsh is already installed
    if [[ "$AUTO_UPDATE" == "true" ]] && ! grep -q "$CHECK_UPDATES_PATH --auto" "$ZSHRC_PATH" 2>/dev/null; then
        echo -e "\n# DevToolsZsh auto-update check" >> "$ZSHRC_PATH"
        echo "$CHECK_UPDATES_PATH --auto" >> "$ZSHRC_PATH"
        echo "Auto-update feature has been enabled"
    fi
else
    # Add our scripts to the user's .zshrc
    echo -e "\n# DevToolsZsh initialization" >> "$ZSHRC_PATH"
    echo "source \"$INIT_SCRIPT_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$ENV_LOADER_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$CUSTOM_PROMPT_PATH\"" >> "$ZSHRC_PATH"
    
    # Add auto-update if requested
    if [[ "$AUTO_UPDATE" == "true" ]]; then
        echo -e "\n# DevToolsZsh auto-update check" >> "$ZSHRC_PATH"
        echo "$CHECK_UPDATES_PATH --auto" >> "$ZSHRC_PATH"
        echo "Auto-update feature has been enabled"
    fi
    
    echo "DevToolsZsh has been installed! Added to $ZSHRC_PATH"
fi

# Inform the user to restart their terminal
echo "Please restart your terminal or start a new session for changes to take effect."
echo "Alternatively, you can run: source ~/.zshrc"

echo "You can toggle between showing the full path and just the current directory by typing: toggle_path_display"
echo -e "\nTo manage plugins, use: list_plugins, enable_plugin, disable_plugin"
if [[ "$AUTO_UPDATE" == "false" ]]; then
    echo -e "\nTo check for updates, run: $CHECK_UPDATES_PATH"
    echo "To enable auto-updates, reinstall with: $SCRIPT_DIR/install.sh --auto-update"
else
    echo -e "\nAuto-updates are enabled. Updates will be checked each time you open a new terminal."
fi
