#!/bin/zsh

# Plugin metadata
PLUGIN_NAME="git_helpers"
PLUGIN_DESCRIPTION="Git helper functions for DevToolsZsh"
PLUGIN_VERSION="1.0.0"
PLUGIN_AUTHOR="Caden Finley"

# Function to display git status in a cleaner format
function git_status_clean() {
    git status -s
}

# Function to perform a quick commit with a message
function git_quick_commit() {
    if [[ -z "$1" ]]; then
        echo "Usage: git_quick_commit <commit_message>"
        return 1
    fi
    
    git add .
    git commit -m "$1"
    echo "Changes committed with message: $1"
}

# Function to undo the last commit but keep changes
function git_undo_commit() {
    git reset --soft HEAD~1
    echo "Last commit undone, changes preserved"
}

# Aliases
alias gsc="git_status_clean"
alias gqc="git_quick_commit"
alias guc="git_undo_commit"

# Initialization message
echo "Plugin '$PLUGIN_NAME' v$PLUGIN_VERSION loaded"
