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
        sed -i.bak '/^export DEVTOOLSZSH_THEME=/d' ~/.zshrc
        echo "export DEVTOOLSZSH_THEME=\"$1\"" >> ~/.zshrc
        export DEVTOOLSZSH_THEME="$1"
        load_environment
        echo "Theme switched to $1"
    else
        echo "Theme '$1' not found"
        return 1
    fi
}

# Initial load
load_environment
