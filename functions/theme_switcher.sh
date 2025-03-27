#!/bin/zsh

function load_environment() {
    # Get absolute path to the base directory
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    
    # Use absolute paths for theme and prompt
    THEME_PATH="${BASE_DIR}/themes/${DEVTOOLSZSH_THEME:-default}.sh"
    if [[ -f "$THEME_PATH" ]]; then
        source "$THEME_PATH"
    else
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
        load_environment
        echo "Theme switched to $1"
        
        # Save theme to ~/.zshrc
        if grep -q 'export DEVTOOLSZSH_THEME=' ~/.zshrc; then
            sed -i.bak "s|^export DEVTOOLSZSH_THEME=.*|export DEVTOOLSZSH_THEME=\"$1\"|g" ~/.zshrc
        else
            echo "export DEVTOOLSZSH_THEME=\"$1\"" >> ~/.zshrc
        fi
    else
        echo "Theme '$1' not found"
        return 1
    fi
}

# Initial load
load_environment
