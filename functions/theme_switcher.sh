#!/bin/zsh

function load_environment() {
    # Get absolute path to the base directory
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    
    # Use absolute paths for theme and prompt
    THEME_PATH="${BASE_DIR}/themes/${DEVTOOLSZSH_THEME:-default}.sh"
    if [[ -f "$THEME_PATH" ]]; then
        source "$THEME_PATH"
    else
        echo "Warning: Theme ${DEVTOOLSZSH_THEME} not found, falling back to default"
        export DEVTOOLSZSH_THEME="default"
        source "${BASE_DIR}/themes/default.sh"
    fi
    
    # Load prompt using absolute path
    source "${BASE_DIR}/prompt/custom_prompt.sh"
    
    # Force zsh to re-evaluate the prompt
    zle reset-prompt 2>/dev/null || true
    
    # Set theme to persist across sessions
    export CURRENT_DEVTOOLSZSH_THEME="$DEVTOOLSZSH_THEME"
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
        
        # Source the theme file first
        source "$THEME_PATH"
        
        # Then load the entire environment
        load_environment
        
        echo "Theme switched to $1"
        
        # Save theme persistently to ~/.zshrc - ensure we're actually updating correctly
        if grep -q 'export DEVTOOLSZSH_THEME=' ~/.zshrc; then
            # Replace existing theme setting - use a more reliable sed pattern
            sed -i.bak 's/^export DEVTOOLSZSH_THEME=.*$/export DEVTOOLSZSH_THEME="'$1'"/' ~/.zshrc
        else
            # Add new theme setting
            echo "export DEVTOOLSZSH_THEME=\"$1\"" >> ~/.zshrc
        fi
        
        # Verify the theme was correctly saved
        if grep -q "export DEVTOOLSZSH_THEME=\"$1\"" ~/.zshrc; then
            echo "Theme '$1' successfully saved for future terminal sessions"
        else
            echo "Warning: There was an issue saving the theme preference"
        fi
    else
        echo "Theme '$1' not found"
        return 1
    fi
}

function list_themes() {
    BASE_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )"
    echo "Available themes:"
    for theme in "${BASE_DIR}"/themes/*.sh; do
        theme_name=$(basename "$theme" .sh)
        if [[ "$theme_name" == "$DEVTOOLSZSH_THEME" ]]; then
            echo "* $theme_name (current)"
        else
            echo "  $theme_name"
        fi
    done
}

# Load theme on script initialization if not already loaded
if [[ -z "$CURRENT_DEVTOOLSZSH_THEME" || "$CURRENT_DEVTOOLSZSH_THEME" != "$DEVTOOLSZSH_THEME" ]]; then
    load_environment
fi