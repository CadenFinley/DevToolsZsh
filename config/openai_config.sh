#!/bin/zsh

# OpenAI Engine Configuration

# API Configuration
OPENAI_API_KEY=""
OPENAI_MODEL="gpt-3.5-turbo"

# Assistant Configuration
OPENAI_ASSISTANT_TYPE="chat"
OPENAI_INITIAL_INSTRUCTION="You are a helpful AI assistant."

# Response Configuration
OPENAI_MAX_PROMPT_LENGTH=-1
OPENAI_CACHE_TOKENS=false
OPENAI_MAX_PROMPT_PRECISION=false
OPENAI_DYNAMIC_PROMPT_LENGTH=false
OPENAI_DYNAMIC_PROMPT_LENGTH_SCALE=5
OPENAI_TIMEOUT_SECONDS=300

# File System Configuration
OPENAI_SAVE_DIRECTORY="$HOME/openai_output"

# Command Capture Configuration
OPENAI_COMMAND_CAPTURE_ENABLED=true

# Load user's personal configuration if it exists
PERSONAL_CONFIG_PATH="$HOME/.openai_config.sh"
if [[ -f "$PERSONAL_CONFIG_PATH" ]]; then
    source "$PERSONAL_CONFIG_PATH"
fi
