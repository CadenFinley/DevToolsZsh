#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
ENV_LOADER_PATH="$SCRIPT_DIR/functions/environment_loader.sh"
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
ZSHRC_PATH="$HOME/.zshrc"

echo "Uninstalling DevToolsZsh..."

# Create a temporary file
TEMP_FILE=$(mktemp)

# Remove DevToolsZsh entries from .zshrc
if grep -q "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$ENV_LOADER_PATH" "$ZSHRC_PATH"; then
    # Copy .zshrc without the DevToolsZsh lines
    grep -v "DevToolsZsh\|source.*$CUSTOM_PROMPT_PATH\|source.*$INIT_SCRIPT_PATH\|source.*$ENV_LOADER_PATH" "$ZSHRC_PATH" > "$TEMP_FILE"
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

# Unload any enabled plugins (this won't persist but might help in the current session)
echo "Note: Any plugin functions or aliases from this session will remain available until you restart your shell."

# Automatically source .zshrc to apply changes immediately
if [[ -n "$ZSH_VERSION" ]]; then
    # If running in Zsh, source directly
    echo "Restoring default prompt in current session..."
    source "$HOME/.zshrc"
else
    # If running in another shell, attempt to source using zsh
    echo "Attempting to restore default prompt..."
    zsh -c "source $HOME/.zshrc" 2>/dev/null || echo "Please restart your terminal or run: source ~/.zshrc"
fi
