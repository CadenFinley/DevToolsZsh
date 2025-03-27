#!/bin/zsh

# Ocean Theme for DevToolsZsh
# Author: GitHub Copilot
# Description: A soothing ocean-inspired color theme

# Define ocean-themed colors
export OCEAN_DEEP_BLUE="%F{27}"       # Deep blue for primary elements
export OCEAN_LIGHT_BLUE="%F{39}"      # Light blue for secondary elements
export OCEAN_TEAL="%F{37}"            # Teal for accents
export OCEAN_SEAFOAM="%F{122}"        # Seafoam green for highlights
export OCEAN_SAND="%F{222}"           # Sandy color for contrast
export OCEAN_CORAL="%F{209}"          # Coral for warnings/errors
export OCEAN_WHITE="%F{255}"          # White for standard text
export OCEAN_GRAY="%F{242}"           # Gray for subtle elements
export COLOR_RESET="%f"               # Reset color to default

# Set color variables used by prompt and other elements
export PROMPT_USER_COLOR="$OCEAN_LIGHT_BLUE"
export PROMPT_HOST_COLOR="$OCEAN_TEAL"
export PROMPT_DIR_COLOR="$OCEAN_DEEP_BLUE"
export PROMPT_GIT_BRANCH_COLOR="$OCEAN_SEAFOAM"
export PROMPT_GIT_DIRTY_COLOR="$OCEAN_CORAL"
export PROMPT_SYMBOL_COLOR="$OCEAN_SAND"
export PROMPT_TIME_COLOR="$OCEAN_GRAY"

# Define colors for command line syntax highlighting
export HIGHLIGHT_COMMAND="$OCEAN_DEEP_BLUE"
export HIGHLIGHT_ARGUMENTS="$OCEAN_TEAL"
export HIGHLIGHT_ERROR="$OCEAN_CORAL"
export HIGHLIGHT_SUCCESS="$OCEAN_SEAFOAM"

# Theme description for display in theme lists
export THEME_DESCRIPTION="A soothing ocean-inspired color theme with blues and teals"

# Set LS_COLORS for ocean theme
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# Notify that theme was loaded
echo "Ocean theme loaded. Dive into your code!"
