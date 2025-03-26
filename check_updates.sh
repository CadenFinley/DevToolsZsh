#!/bin/bash

# Script to check for updates in DevToolsZsh repository

# Determine the script directory
if [[ -d "$HOME/.devtoolszsh" ]]; then
    SCRIPT_DIR="$HOME/.devtoolszsh"
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        echo "Error: Git is not installed. Please install git to check for updates."
        return 1
    fi
    return 0
}

# Function to check if the directory is a git repository
check_git_repo() {
    if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
        echo "Error: The installation directory is not a git repository."
        echo "If you installed via the installer script, you may need to reinstall using:"
        echo "git clone https://github.com/cadenfinley/DevToolsZsh.git"
        return 1
    fi
    return 0
}

# Check for updates
check_for_updates() {
    local silent_mode=$1
    
    if [[ "$silent_mode" != "silent" ]]; then
        echo "Checking for DevToolsZsh updates..."
    fi
    
    # Change to the script directory
    cd "$SCRIPT_DIR" || return 1
    
    # Save the current branch
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    
    # Fetch the latest changes
    git fetch origin --quiet
    if [[ $? -ne 0 ]]; then
        if [[ "$silent_mode" != "silent" ]]; then
            echo "Error: Failed to fetch updates from the repository."
        fi
        return 1
    fi
    
    # Check if there are changes
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    
    if [[ "$LOCAL" == "$REMOTE" ]]; then
        if [[ "$silent_mode" != "silent" ]]; then
            echo "DevToolsZsh is up to date!"
        fi
        return 0
    elif [[ "$LOCAL" == "$BASE" ]]; then
        echo "Updates are available for DevToolsZsh!"
        
        if [[ "$silent_mode" != "silent" ]]; then
            echo -n "Would you like to update now? [y/N] "
            read -r response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo "Updating DevToolsZsh..."
                git pull
                if [[ $? -eq 0 ]]; then
                    echo "Update successful!"
                    echo "You may need to restart your shell or run 'source ~/.zshrc' to apply the changes."
                else
                    echo "Update failed. Please try again later or update manually."
                    return 1
                fi
            else
                echo "Update canceled. Run 'check_for_updates' again when you want to update."
            fi
        else
            echo "Run 'check_for_updates' to install the updates."
        fi
    elif [[ "$REMOTE" == "$BASE" ]]; then
        if [[ "$silent_mode" != "silent" ]]; then
            echo "Your local repository has unpushed changes."
            echo "This might be due to local modifications or a fork."
        fi
    else
        if [[ "$silent_mode" != "silent" ]]; then
            echo "Your local repository has diverged from the remote repository."
            echo "You may need to manually resolve this situation."
        fi
    fi
    
    return 0
}

# Main execution
main() {
    check_git || return 1
    check_git_repo || return 1
    check_for_updates "$1"
}

# Run the main function with command line parameter (if any)
main "$1"
