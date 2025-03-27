#!/bin/zsh

function load_environment() {
    # Get absolute path to the base directory
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    
    # Set default theme if not already set from .zshrc
    if [[ -z "$DEVTOOLSZSH_THEME" ]]; then
        export DEVTOOLSZSH_THEME="default"
    fi
    
    # Use absolute paths for theme and prompt
    THEME_PATH="${BASE_DIR}/themes/${DEVTOOLSZSH_THEME}.sh"
    
    if [[ -f "$THEME_PATH" ]]; then
        source "$THEME_PATH"
    else
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