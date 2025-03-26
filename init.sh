#!/bin/zsh

# Initialize DevToolsZsh environment variables
if [[ -z "$DEVTOOLSZSH_INITIALIZED" ]]; then
    export DEVTOOLSZSH_INITIALIZED=true
    export DEVTOOLSZSH_DISPLAY_WHOLE_PATH=${DEVTOOLSZSH_DISPLAY_WHOLE_PATH:-false}
    export DEVTOOLSZSH_THEME=${DEVTOOLSZSH_THEME:-default}
    export DEVTOOLSZSH_AUTO_UPDATE=${DEVTOOLSZSH_AUTO_UPDATE:-false}
    
    # Get base directory
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"
    export DEVTOOLSZSH_BASE_DIR="$BASE_DIR"
    
    # Version information
    CURRENT_VERSION="1.0.0"
    
    # Color definitions
    PURPLE_COLOR_BOLD="\033[1;35m"
    RESET_COLOR="\033[0m"
    
    # Title and creator information
    TITLE_LINE="DevToolsZsh v${CURRENT_VERSION} - Caden Finley (c) 2025"
    CREATED_LINE="Created 2025 @ ${PURPLE_COLOR_BOLD}Abilene Christian University${RESET_COLOR}"
    
    # Display title and creator information
    echo $TITLE_LINE
    echo $CREATED_LINE
    
    # Set terminal window title
    function set_terminal_title() {
        echo -ne "\033]0;DevToolsZsh\007"
    }
    
    # Set the initial terminal title
    set_terminal_title
    
    # Add precmd hook to update terminal title on directory change
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd set_terminal_title
    
    # Function to uninstall DevToolsZsh
    function uninstall_devtoolszsh() {
        echo "Running DevToolsZsh uninstaller..."
        bash "$DEVTOOLSZSH_BASE_DIR/uninstall.sh"
    }
    
    # Function to check for updates
    function check_for_updates() {
        bash "$DEVTOOLSZSH_BASE_DIR/check_updates.sh"
    }
    
    # Function to enable automatic updates
    function enable_auto_updates() {
        export DEVTOOLSZSH_AUTO_UPDATE=true
        echo "Auto-updates enabled. DevToolsZsh will check for updates each time a terminal is opened."
        # Save setting to zshrc
        if ! grep -q "export DEVTOOLSZSH_AUTO_UPDATE=true" ~/.zshrc; then
            echo "export DEVTOOLSZSH_AUTO_UPDATE=true" >> ~/.zshrc
            echo "Setting saved in ~/.zshrc"
        fi
    }
    
    # Function to disable automatic updates
    function disable_auto_updates() {
        export DEVTOOLSZSH_AUTO_UPDATE=false
        echo "Auto-updates disabled."
        # Remove setting from zshrc
        sed -i.bak '/export DEVTOOLSZSH_AUTO_UPDATE=true/d' ~/.zshrc
        echo "Setting removed from ~/.zshrc"
    }
    
    # Function to manually check and apply updates
    function update_devtoolszsh() {
        check_for_updates
    }
    
    # Check for updates on startup if auto-update is enabled
    if [[ "$DEVTOOLSZSH_AUTO_UPDATE" == "true" ]]; then
        bash "$DEVTOOLSZSH_BASE_DIR/check_updates.sh" silent
    fi
    
    # Load plugins
    source "$BASE_DIR/functions/plugin_loader.sh"
fi
