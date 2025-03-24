#!/bin/bash

# Check if installed in the user's home directory
if [[ -d "$HOME/.devtoolszsh" ]]; then
    SCRIPT_DIR="$HOME/.devtoolszsh"
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
ENV_LOADER_PATH="$SCRIPT_DIR/functions/environment_loader.sh"
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
CHECK_UPDATES_PATH="$SCRIPT_DIR/check_updates.sh"
ZSHRC_PATH="$HOME/.zshrc"

echo "Uninstalling DevToolsZsh..."

# Create a temporary file
TEMP_FILE=$(mktemp)

# Remove DevToolsZsh entries from .zshrc
if grep -q "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$ENV_LOADER_PATH\|$CHECK_UPDATES_PATH" "$ZSHRC_PATH"; then
    # Copy .zshrc without the DevToolsZsh lines
    grep -v "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$ENV_LOADER_PATH\|$CHECK_UPDATES_PATH" "$ZSHRC_PATH" > "$TEMP_FILE"
    # Replace the original file
    mv "$TEMP_FILE" "$ZSHRC_PATH"
    echo "DevToolsZsh has been removed from $ZSHRC_PATH"
else
    echo "DevToolsZsh was not found in $ZSHRC_PATH"
    rm -f "$TEMP_FILE"
fi

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
if [ -n "$DEVTOOLSZSH_BASE_DIR" ]; then
    unset DEVTOOLSZSH_BASE_DIR
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
    echo -n "Do you want to remove the DevToolsZsh installation directory? [y/N] "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "$HOME/.devtoolszsh"
        echo "Removed installation directory from $HOME/.devtoolszsh"
    else
        echo "Installation directory remains at $HOME/.devtoolszsh"
    fi
fi

# Unload any enabled plugins (this won't persist but might help in the current session)
echo "Note: Any plugin functions or aliases from this session will remain available until you restart your shell."

# Inform the user to restart their terminal
echo "Please restart your terminal or start a new session for changes to take effect."
echo "Alternatively, you can run: source ~/.zshrc"
