#!/bin/zsh

function load_environment() {
    # Get absolute path to the base directory
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    
    # Debug information
    echo "Current DEVTOOLSZSH_THEME value: ${DEVTOOLSZSH_THEME:-not set}"
    
    # Set default theme if not already set from .zshrc
    if [[ -z "$DEVTOOLSZSH_THEME" ]]; then
        export DEVTOOLSZSH_THEME="default"
        echo "No theme was set, defaulting to: default"
    fi
    
    # Use absolute paths for theme and prompt
    THEME_PATH="${BASE_DIR}/themes/${DEVTOOLSZSH_THEME}.sh"
    echo "Looking for theme at: $THEME_PATH"
    
    if [[ -f "$THEME_PATH" ]]; then
        source "$THEME_PATH"
        echo "Successfully loaded theme: $DEVTOOLSZSH_THEME"
    else
        echo "Theme '$DEVTOOLSZSH_THEME' not found, loading default theme"
        export DEVTOOLSZSH_THEME="default"
        source "${BASE_DIR}/themes/default.sh"
    fi
    
    # Load prompt using absolute path
    source "${BASE_DIR}/prompt/custom_prompt.sh"
}

function switch_theme() {
    if [[ -z "$1" ]]; then
        echo "Usage: switch_theme <theme_name>"
        return 1
    fi

    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    THEME_PATH="${BASE_DIR}/themes/$1.sh"
    
    if [[ -f "$THEME_PATH" ]]; then
        export DEVTOOLSZSH_THEME="$1"
        
        # Save theme to zshrc for persistence
        if grep -q "export DEVTOOLSZSH_THEME=" ~/.zshrc; then
            # Replace existing theme setting
            sed -i.bak "s/export DEVTOOLSZSH_THEME=.*/export DEVTOOLSZSH_THEME=\"$1\"/" ~/.zshrc
            echo "Theme setting saved for future sessions"
        else
            # Add new theme setting
            echo "export DEVTOOLSZSH_THEME=\"$1\"" >> ~/.zshrc
            echo "Theme setting added to ~/.zshrc"
        fi
        
        load_environment
        echo "Theme switched to $1"
    else
        echo "Theme '$1' not found"
        return 1
    fi
}

# Initial load
load_environment