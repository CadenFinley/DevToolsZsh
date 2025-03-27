#!/bin/bash

# Check if installed in the user's home directory
if [[ -d "$HOME/.devtoolszsh" ]]; then
    SCRIPT_DIR="$HOME/.devtoolszsh"
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
THEME_SWITCHER_PATH="$SCRIPT_DIR/functions/theme_switcher.sh"
CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
ZSHRC_PATH="$HOME/.zshrc"

echo "Uninstalling DevToolsZsh..."

# Create a temporary file
TEMP_FILE=$(mktemp)

# Remove DevToolsZsh entries from .zshrc
if grep -q "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$THEME_SWITCHER_PATH\|$CHECK_UPDATES_PATH" "$ZSHRC_PATH"; then
    # Copy .zshrc without the DevToolsZsh lines
    grep -v "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$THEME_SWITCHER_PATH\|$CHECK_UPDATES_PATH\|DevToolsZsh auto-update check" "$ZSHRC_PATH" > "$TEMP_FILE"
    
    # Also remove the theme and auto-update settings
    grep -v "^export DEVTOOLSZSH_THEME=\|^export DEVTOOLSZSH_AUTO_UPDATE=" "$TEMP_FILE" > "$TEMP_FILE.2"
    mv "$TEMP_FILE.2" "$TEMP_FILE"
    
    # Replace the original file
    mv "$TEMP_FILE" "$ZSHRC_PATH"
    echo "DevToolsZsh has been removed from $ZSHRC_PATH"
else
    echo "DevToolsZsh was not found in $ZSHRC_PATH"
    rm -f "$TEMP_FILE"
fi

# Clean up backup files that might have been created by sed operations
rm -f "$ZSHRC_PATH.bak" 2>/dev/null

# Reset environment variables
if [ -n "$DEVTOOLSZSH_DISPLAY_WHOLE_PATH" ]; then
    unset DEVTOOLSZSH_DISPLAY_WHOLE_PATH
fi
if [ -n "$DEVTOOLSZSH_INITIALIZED" ]; then
    unset DEVTOOLSZSH_INITIALIZED
fi
if [ -n "$DEVTOOLSZSH_THEME" ]; then
    unset DEVTOOLSZSH_THEME
fi
if [ -n "$CURRENT_DEVTOOLSZSH_THEME" ]; then
    unset CURRENT_DEVTOOLSZSH_THEME
fi
if [ -n "$DEVTOOLSZSH_BASE_DIR" ]; then
    unset DEVTOOLSZSH_BASE_DIR
fi
if [ -n "$DEVTOOLSZSH_AUTO_UPDATE" ]; then
    unset DEVTOOLSZSH_AUTO_UPDATE
fi

# Unset any OpenAI plugin environment variables
if [ -n "$OPENAI_API_KEY" ]; then
    unset OPENAI_API_KEY
fi
if [ -n "$OPENAI_MODEL" ]; then
    unset OPENAI_MODEL
fi
if [ -n "$OPENAI_ASSISTANT_TYPE" ]; then
    unset OPENAI_ASSISTANT_TYPE
fi
if [ -n "$OPENAI_HOOKS_ADDED" ]; then
    unset OPENAI_HOOKS_ADDED
fi

# Ask if the user wants to remove the installation directory
if [[ -d "$HOME/.devtoolszsh" ]]; then
    echo -n "Do you want to remove the DevToolsZsh installation directory (including the .git folder)? [y/N] "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # Check if .git directory exists
        if [[ -d "$HOME/.devtoolszsh/.git" ]]; then
            echo "Removing Git repository and all DevToolsZsh files..."
        else
            echo "Removing all DevToolsZsh files..."
        fi
        
        # Remove the entire directory including hidden files and folders
        rm -rf "$HOME/.devtoolszsh"
        
        # Verify removal
        if [[ ! -d "$HOME/.devtoolszsh" ]]; then
            echo "Successfully removed installation directory from $HOME/.devtoolszsh"
        else
            echo "Warning: There was an issue removing the installation directory."
        fi
    else
        echo "Installation directory remains at $HOME/.devtoolszsh"
    fi
fi

# Unload any enabled plugins (this won't persist but might help in the current session)
echo "Note: Any plugin functions or aliases from this session will remain available until you restart your shell."

# Inform the user to restart their terminal
echo "Please restart your terminal or start a new session for changes to take effect."
echo "Alternatively, you can run: source ~/.zshrc"
