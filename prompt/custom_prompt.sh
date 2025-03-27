#!/bin/zsh

# DevToolsZsh Theme

# Use theme colors with proper wrapping for prompt
SHELL_COLOR="%{${DEVTOOLSZSH_SHELL_COLOR:=\033[1;31m}%}"
DIRECTORY_COLOR="%{${DEVTOOLSZSH_DIRECTORY_COLOR:=\033[1;34m}%}"
BRANCH_COLOR="%{${DEVTOOLSZSH_BRANCH_COLOR:=\033[1;33m}%}"
GIT_COLOR="%{${DEVTOOLSZSH_GIT_COLOR:=\033[1;32m}%}"
RESET_COLOR="%{\033[0m%}"

# Configuration
DISPLAY_WHOLE_PATH=${DEVTOOLSZSH_DISPLAY_WHOLE_PATH:-false}

# Apply theme colors on load or reload
function apply_theme_colors() {
  SHELL_COLOR="%{${DEVTOOLSZSH_SHELL_COLOR:=\033[1;31m}%}"
  DIRECTORY_COLOR="%{${DEVTOOLSZSH_DIRECTORY_COLOR:=\033[1;34m}%}"
  BRANCH_COLOR="%{${DEVTOOLSZSH_BRANCH_COLOR:=\033[1;33m}%}"
  GIT_COLOR="%{${DEVTOOLSZSH_GIT_COLOR:=\033[1;32m}%}"
  RESET_COLOR="%{\033[0m%}"
}

function get_current_filename() {
  echo "${PWD##*/}"
}

function git_custom_status() {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  echo "${ref#refs/heads/}"
}

function build_prompt() {
  # Ensure we have the most current theme colors
  apply_theme_colors
  
  local git_info=""
  local current_dir
  
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git_custom_status)
    if [[ -n "$branch" ]]; then
      if [[ "$DISPLAY_WHOLE_PATH" == "true" ]]; then
        repo_name="$PWD"
      else
        repo_name=$(get_current_filename)
      fi
      git_info="${GIT_COLOR}${repo_name}${RESET_COLOR}${DIRECTORY_COLOR} git:(${RESET_COLOR}${BRANCH_COLOR}${branch}${RESET_COLOR}${DIRECTORY_COLOR})${RESET_COLOR}"
    fi
    
    print -n "${SHELL_COLOR}\$${RESET_COLOR} ${git_info} "
  else
    if [[ "$DISPLAY_WHOLE_PATH" == "true" ]]; then
      current_dir="$PWD"
    else
      current_dir=$(get_current_filename)
    fi
    print -n "${SHELL_COLOR}\$${RESET_COLOR} ${DIRECTORY_COLOR}${current_dir}${RESET_COLOR} "
  fi
}

setopt PROMPT_SUBST
PROMPT='$(build_prompt)'

# Immediately apply theme colors on load
apply_theme_colors

function toggle_path_display() {
  if [[ "$DISPLAY_WHOLE_PATH" == "true" ]]; then
    export DEVTOOLSZSH_DISPLAY_WHOLE_PATH=false
    DISPLAY_WHOLE_PATH=false
    echo "Showing current directory only"
  else
    export DEVTOOLSZSH_DISPLAY_WHOLE_PATH=true
    DISPLAY_WHOLE_PATH=true
    echo "Showing full path"
  fi
}