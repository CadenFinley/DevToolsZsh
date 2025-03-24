#!/bin/zsh

# Initialize DevToolsZsh environment variables
if [[ -z "$DEVTOOLSZSH_INITIALIZED" ]]; then
    export DEVTOOLSZSH_INITIALIZED=true
    export DEVTOOLSZSH_DISPLAY_WHOLE_PATH=${DEVTOOLSZSH_DISPLAY_WHOLE_PATH:-false}
    export DEVTOOLSZSH_THEME=${DEVTOOLSZSH_THEME:-default}
    export DEVTOOLSZSH_AUTO_UPDATE=${DEVTOOLSZSH_AUTO_UPDATE:-true}
    
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
        local user_dir=${PWD##*/}
        echo -ne "\033]0;${user_dir} - DevToolsZsh\007"
    }
    
    # Set the initial terminal title
    set_terminal_title
    
    # Add precmd hook to update terminal title on directory change
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd set_terminal_title
    
    # Automatically check for updates if enabled
    if [[ "$DEVTOOLSZSH_AUTO_UPDATE" == "true" ]]; then
        "$BASE_DIR/check_updates.sh" --auto
    fi
    
    # Function to uninstall DevToolsZsh
    function uninstall_devtoolszsh() {
        echo "Running DevToolsZsh uninstaller..."
        bash "$DEVTOOLSZSH_BASE_DIR/uninstall.sh"
    }
    
    # Load plugins
    source "$BASE_DIR/functions/plugin_loader.sh"
fi
