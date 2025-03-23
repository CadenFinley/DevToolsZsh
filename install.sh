#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CUSTOM_PROMPT_PATH="$SCRIPT_DIR/prompt/custom_prompt.sh"
INIT_SCRIPT_PATH="$SCRIPT_DIR/init.sh"
ENV_LOADER_PATH="$SCRIPT_DIR/functions/environment_loader.sh"
PLUGIN_LOADER_PATH="$SCRIPT_DIR/functions/plugin_loader.sh"
ENABLED_PLUGINS_FILE="$SCRIPT_DIR/.enabled_plugins"
ZSHRC_PATH="$HOME/.zshrc"

echo "Installing DevToolsZsh custom prompt..."

# Make scripts executable
chmod +x "$CUSTOM_PROMPT_PATH"
chmod +x "$INIT_SCRIPT_PATH"
chmod +x "$ENV_LOADER_PATH"
chmod +x "$PLUGIN_LOADER_PATH"

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
else
    # Add our scripts to the user's .zshrc
    echo -e "\n# DevToolsZsh initialization" >> "$ZSHRC_PATH"
    echo "source \"$INIT_SCRIPT_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$ENV_LOADER_PATH\"" >> "$ZSHRC_PATH"
    echo "source \"$CUSTOM_PROMPT_PATH\"" >> "$ZSHRC_PATH"
    echo "DevToolsZsh has been installed! Added to $ZSHRC_PATH"
fi

# Automatically source .zshrc to apply changes immediately
if [[ -n "$ZSH_VERSION" ]]; then
    # If running in Zsh, source directly
    echo "Activating DevToolsZsh in current session..."
    source "$HOME/.zshrc"
else
    # If running in another shell, attempt to source using zsh
    echo "Attempting to activate DevToolsZsh..."
    zsh -c "source $HOME/.zshrc" 2>/dev/null || echo "Please restart your terminal or run: source ~/.zshrc"
fi

echo "You can toggle between showing the full path and just the current directory by typing: toggle_path_display"
echo -e "\nTo manage plugins, use: list_plugins, enable_plugin, disable_plugin"
