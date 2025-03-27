#!/bin/bash

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
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
THEME_SWITCHER_PATH="$SCRIPT_DIR/functions/theme_switcher.sh"

CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
ENABLED_PLUGINS_FILE="$SCRIPT_DIR/.enabled_plugins"
ZSHRC_PATH="$HOME/.zshrc"
INSTALL_DIR="$HOME/.devtoolszsh"

echo "Installing DevToolsZsh custom prompt..."

# Install to user's home directory if run via curl
if [[ "$0" == "bash" ]]; then
    # Create the installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy all files to the installation directory, including hidden files and the .git directory
    echo "Copying files to $INSTALL_DIR..."
    cp -R "$TEMP_DIR"/. "$INSTALL_DIR"
    
    # Verify that the .git directory was copied
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo "Git repository preserved for update functionality"
    else
        echo "Warning: Git repository was not copied. Updates may not work correctly."
    fi
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    
    # Update paths to use the installation directory
    SCRIPT_DIR="$INSTALL_DIR"
    CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
    INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
    PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
    THEME_SWITCHER_PATH="$SCRIPT_DIR/functions/theme_switcher.sh"
    CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
    ENABLED_PLUGINS_FILE="$SCRIPT_DIR/.enabled_plugins"
fi

# Make scripts executable
chmod +x "$CUSTOM_PROMPT_PATH"
chmod +x "$INIT_SCRIPT_PATH"
chmod +x "$PLUGIN_LOADER_PATH"
chmod +x "$CHECK_UPDATES_PATH"
chmod +x "$THEME_SWITCHER_PATH"

# Create the enabled plugins file if it doesn't exist
if [[ ! -f "$ENABLED_PLUGINS_FILE" ]]; then
    echo "# DevToolsZsh Enabled Plugins" > "$ENABLED_PLUGINS_FILE"
    echo "# Add one plugin name per line" >> "$ENABLED_PLUGINS_FILE"
    echo "# Lines starting with # are ignored" >> "$ENABLED_PLUGINS_FILE"
    echo "Created enabled plugins file"
fi

# Check if the entries already exist in .zshrc
if grep -q "source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$THEME_SWITCHER_PATH" "$ZSHRC_PATH" 2>/dev/null; then
    echo "DevToolsZsh is already installed in $ZSHRC_PATH"
    
    # Remove any existing auto-update entries if they exist
    if grep -q "DevToolsZsh auto-update check" "$ZSHRC_PATH"; then
        TEMP_FILE=$(mktemp)
        grep -v "DevToolsZsh auto-update check\|$CHECK_UPDATES_PATH" "$ZSHRC_PATH" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$ZSHRC_PATH"
        echo "Removed auto-update feature"
    fi
else
    # Add our scripts to the user's .zshrc
    echo -e "\n# DevToolsZsh initialization" >> "$ZSHRC_PATH"
    echo "source \"$INIT_SCRIPT_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$CUSTOM_PROMPT_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$THEME_SWITCHER_PATH\"" >> "$ZSHRC_PATH"
    
    echo "DevToolsZsh has been installed! Added to $ZSHRC_PATH"
fi

# Inform the user to restart their terminal
echo "Please restart your terminal or start a new session for changes to take effect."
echo "Alternatively, you can run: source ~/.zshrc"
