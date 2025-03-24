#!/bin/zsh

# Plugin metadata
PLUGIN_NAME="openai_engine"
PLUGIN_DESCRIPTION="OpenAI interface for DevToolsZsh"
PLUGIN_VERSION="1.0.0"
PLUGIN_AUTHOR="Caden Finley"

# Load configuration
CONFIG_DIR="$( cd "$( dirname "${(%):-%x}" )/.." && pwd )/config"
CONFIG_FILE="${CONFIG_DIR}/openai_config.sh"

# Function to initialize config directory and file
function openai_init_config() {
    # Create config directory if it doesn't exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Create config file if it doesn't exist
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << EOF
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
OPENAI_SAVE_DIRECTORY="\$HOME/openai_output"

# Command Capture Configuration
OPENAI_COMMAND_CAPTURE_ENABLED=true

# Load user's personal configuration if it exists
PERSONAL_CONFIG_PATH="\$HOME/.openai_config.sh"
if [[ -f "\$PERSONAL_CONFIG_PATH" ]]; then
    source "\$PERSONAL_CONFIG_PATH"
fi
EOF
    fi
}

# Initialize config
openai_init_config

# Load default configuration values
OPENAI_API_KEY=""
OPENAI_MODEL="gpt-3.5-turbo"
OPENAI_ASSISTANT_TYPE="chat"
OPENAI_INITIAL_INSTRUCTION="You are a helpful AI assistant."
OPENAI_MAX_PROMPT_LENGTH=-1
OPENAI_CACHE_TOKENS=false
OPENAI_MAX_PROMPT_PRECISION=false
OPENAI_DYNAMIC_PROMPT_LENGTH=false
OPENAI_DYNAMIC_PROMPT_LENGTH_SCALE=5
OPENAI_TIMEOUT_SECONDS=300
OPENAI_SAVE_DIRECTORY="$HOME/openai_output"
OPENAI_COMMAND_CAPTURE_ENABLED=true

# Source the configuration file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# File management
OPENAI_FILES=()
OPENAI_FILE_CONTENTS=""
OPENAI_CHAT_CACHE=()

# Command history tracking
OPENAI_LAST_COMMAND=""
OPENAI_LAST_OUTPUT=""

# Function to set the OpenAI API key
function openai_set_api_key() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_set_api_key <api_key>"
        return 1
    fi
    
    OPENAI_API_KEY="$1"
    echo "OpenAI API key set successfully"
}

# Function to set the OpenAI model
function openai_set_model() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_set_model <model>"
        echo "Available models: gpt-3.5-turbo, gpt-4, etc."
        return 1
    fi
    
    OPENAI_MODEL="$1"
    echo "OpenAI model set to: $OPENAI_MODEL"
}

# Function to set the assistant type
function openai_set_assistant_type() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_set_assistant_type <type>"
        echo "Available types: chat, file-search, code-interpreter"
        return 1
    fi
    
    if [[ "$1" != "chat" && "$1" != "file-search" && "$1" != "code-interpreter" ]]; then
        echo "Invalid assistant type. Available types: chat, file-search, code-interpreter"
        return 1
    fi
    
    OPENAI_ASSISTANT_TYPE="$1"
    echo "Assistant type set to: $OPENAI_ASSISTANT_TYPE"
}

# Function to capture command output
function openai_capture_command() {
    # Store the command
    OPENAI_LAST_COMMAND="$1"
    
    # Execute the command and capture its output
    OPENAI_LAST_OUTPUT=$(eval "$1" 2>&1)
    
    # Display the output
    echo "$OPENAI_LAST_OUTPUT"
}

# Function to get AI help with the last command
function openai_aihelp() {
    local message="$1"
    local help_request=""
    
    # If command history capture not manually used, try to get the last command from history
    if [[ -z "$OPENAI_LAST_COMMAND" && $OPENAI_COMMAND_CAPTURE_ENABLED == true ]]; then
        OPENAI_LAST_COMMAND=$(fc -ln -1)
        # Skip this command itself
        if [[ "$OPENAI_LAST_COMMAND" == *"openai_aihelp"* || "$OPENAI_LAST_COMMAND" == *"aihelp"* ]]; then
            OPENAI_LAST_COMMAND=$(fc -ln -2 -2)
            # Also get the output if possible
            OPENAI_LAST_OUTPUT=$(tail -n 20 $TTY)
        fi
    fi
    
    # If no message provided, use a default
    if [[ -z "$message" ]]; then
        help_request="I ran this command: '$OPENAI_LAST_COMMAND' and got this output: '$OPENAI_LAST_OUTPUT'. Can you help me understand what's happening and how to fix any issues?"
    else
        help_request="I ran this command: '$OPENAI_LAST_COMMAND' and got this output: '$OPENAI_LAST_OUTPUT'. $message"
    fi
    
    # Check if we have a command and output to analyze
    if [[ -z "$OPENAI_LAST_COMMAND" ]]; then
        echo "No previous command found. Run a command first before asking for help."
        return 1
    fi
    
    # Call the API with the help request
    openai_chat "$help_request"
}

# Function to set the initial instruction
function openai_set_instruction() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_set_instruction <instruction>"
        return 1
    fi
    
    OPENAI_INITIAL_INSTRUCTION="$1"
    echo "Initial instruction set"
}

# Function to add a file to be processed
function openai_add_file() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_add_file <file_path>"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "Error: File not found: $1"
        return 1
    fi
    
    OPENAI_FILES+=("$1")
    echo "Added file: $1"
    openai_process_file_contents
}

# Function to clear all files
function openai_clear_files() {
    OPENAI_FILES=()
    OPENAI_FILE_CONTENTS=""
    echo "All files cleared"
}

# Function to process file contents
function openai_process_file_contents() {
    OPENAI_FILE_CONTENTS=""
    
    for file in "${OPENAI_FILES[@]}"; do
        local filename=$(basename "$file")
        OPENAI_FILE_CONTENTS+="File: $filename\n"
        
        if [[ "$file" == *.txt ]]; then
            OPENAI_FILE_CONTENTS+=$(cat "$file")
        else
            OPENAI_FILE_CONTENTS+=$(cat "$file")
        fi
        
        OPENAI_FILE_CONTENTS+="\n"
    done
}

# Function to clear chat cache
function openai_clear_chat_cache() {
    OPENAI_CHAT_CACHE=()
    echo "Chat cache cleared"
}

# Function to build a prompt
function openai_build_prompt() {
    local message="$1"
    local prompt=""
    
    # Process file contents if any
    if [[ ${#OPENAI_FILES[@]} -gt 0 ]]; then
        openai_process_file_contents
    fi
    
    # Add initial instruction
    prompt+="$OPENAI_INITIAL_INSTRUCTION"
    
    # Add prompt length limit if set
    if [[ $OPENAI_MAX_PROMPT_LENGTH -gt 0 ]]; then
        local prompt_length=$OPENAI_MAX_PROMPT_LENGTH
        if [[ $OPENAI_DYNAMIC_PROMPT_LENGTH == true ]]; then
            prompt_length=$(( ${#message} * $OPENAI_DYNAMIC_PROMPT_LENGTH_SCALE ))
            if [[ $prompt_length -lt 100 ]]; then
                prompt_length=100
            fi
        fi
        prompt+=" Please keep the response length under $prompt_length characters."
    fi
    
    # Add chat history for chat type
    if [[ ${#OPENAI_CHAT_CACHE[@]} -gt 0 && "$OPENAI_ASSISTANT_TYPE" != "code-interpreter" ]]; then
        prompt+=" This is the chat history between you and the user: [ "
        for chat in "${OPENAI_CHAT_CACHE[@]}"; do
            prompt+="$chat "
        done
        prompt+="] This is the latest message from the user: [$message] "
    else
        if [[ "$OPENAI_ASSISTANT_TYPE" == "code-interpreter" ]]; then
            prompt+="$message Please only return code in your response if edits were made and only make edits that the I request. Please use markdown syntax in your response for the code. Include only the exact file name and only the file name in the line above."
        else
            prompt+=" This is the first message from the user: [$message] "
        fi
    fi
    
    # Add file contents for file-search or code-interpreter
    if [[ "$OPENAI_ASSISTANT_TYPE" == "file-search" && -n "$OPENAI_FILE_CONTENTS" ]]; then
        prompt+=" This is the contents of the provided files from the user: [ $OPENAI_FILE_CONTENTS ]"
        if [[ $OPENAI_CACHE_TOKENS == true ]]; then
            prompt+=" Please keep this content of these files in cached tokens."
        fi
    fi
    
    if [[ "$OPENAI_ASSISTANT_TYPE" == "code-interpreter" && -n "$OPENAI_FILE_CONTENTS" ]]; then
        prompt+=" User Files: [ $OPENAI_FILE_CONTENTS ]"
    fi
    
    echo "$prompt"
}

# Function to make a call to the OpenAI API
function openai_call_api() {
    local message="$1"
    
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "Error: API key not set. Use openai_set_api_key to set it."
        return 1
    fi
    
    local prompt=$(openai_build_prompt "$message")
    
    # Filter message to avoid special characters issues
    prompt=$(echo "$prompt" | tr -cd '[:alnum:] .-_~')
    
    # Create a temporary file for the request body
    local temp_request=$(mktemp)
    local temp_response=$(mktemp)
    
    # Create the request body
    cat > "$temp_request" << EOF
{
    "model": "$OPENAI_MODEL",
    "messages": [
        {
            "role": "user",
            "content": "$prompt"
        }
    ]
}
EOF
    
    # Make the API call
    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d @"$temp_request" \
        -o "$temp_response" \
        --max-time $OPENAI_TIMEOUT_SECONDS
    
    # Check if the API call was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: API call failed"
        rm "$temp_request" "$temp_response"
        return 1
    fi

    # Check if jq is installed
    if command -v jq &> /dev/null; then
        # Use jq to extract content (robust JSON parsing)
        local response=$(jq -r '.choices[0].message.content // empty' "$temp_response")
        
        # If jq returns empty or error, check if there's an error message
        if [[ -z "$response" ]]; then
            local error_msg=$(jq -r '.error.message // "Unknown error"' "$temp_response")
            echo "Error: $error_msg"
            cat "$temp_response"
            rm "$temp_request" "$temp_response"
            return 1
        fi
    else
        # Fallback method if jq is not installed
        local response=$(cat "$temp_response" | grep -o '"content":"[^"]*"' | sed 's/"content":"//;s/"//')
        
        # Check if response contains error
        if [[ -z "$response" && $(cat "$temp_response" | grep -o '"error":') ]]; then
            echo "Error in API response (install jq for better error handling):"
            cat "$temp_response"
            rm "$temp_request" "$temp_response"
            return 1
        fi
    fi
    
    # Clean up temporary files
    rm "$temp_request" "$temp_response"
    
    # Add to chat cache if not code-interpreter
    if [[ "$OPENAI_ASSISTANT_TYPE" != "code-interpreter" && -n "$response" ]]; then
        OPENAI_CHAT_CACHE+=("User: $message")
        OPENAI_CHAT_CACHE+=("AI: $response")
    fi
    
    echo "$response"
}

# Main function to interact with ChatGPT
function openai_chat() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_chat <message>"
        return 1
    fi
    
    local message="$1"
    local response=$(openai_call_api "$message")
    
    # Format the response if needed
    echo "$response"
}

# Set save directory for code-interpreter
function openai_set_save_directory() {
    if [[ -z "$1" ]]; then
        echo "Usage: openai_set_save_directory <directory>"
        return 1
    fi
    
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create directory: $1"
            return 1
        fi
    fi
    
    OPENAI_SAVE_DIRECTORY="$1"
    echo "Save directory set to: $OPENAI_SAVE_DIRECTORY"
}

# Toggle cache tokens
function openai_toggle_cache_tokens() {
    OPENAI_CACHE_TOKENS=$((! $OPENAI_CACHE_TOKENS))
    echo "Cache tokens: $OPENAI_CACHE_TOKENS"
}

# Toggle dynamic prompt length
function openai_toggle_dynamic_prompt_length() {
    OPENAI_DYNAMIC_PROMPT_LENGTH=$((! $OPENAI_DYNAMIC_PROMPT_LENGTH))
    echo "Dynamic prompt length: $OPENAI_DYNAMIC_PROMPT_LENGTH"
}

# Toggle max prompt precision
function openai_toggle_max_prompt_precision() {
    OPENAI_MAX_PROMPT_PRECISION=$((! $OPENAI_MAX_PROMPT_PRECISION))
    echo "Max prompt precision: $OPENAI_MAX_PROMPT_PRECISION"
}

# Test API key
function openai_test_api_key() {
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "Error: API key not set. Use openai_set_api_key to set it."
        return 1
    fi
    
    echo "Testing API key..."
    
    local response=$(curl -s -X GET "https://api.openai.com/v1/engines" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -w "%{http_code}" \
        -o /dev/null)
    
    if [[ "$response" == "200" ]]; then
        echo "API key is valid"
        return 0
    else
        echo "API key is invalid (HTTP response: $response)"
        return 1
    fi
}

# Function to save current configuration
function openai_save_config() {
    local save_path="$CONFIG_FILE"
    if [[ -n "$1" ]]; then
        save_path="$1"
    fi
    
    # Ensure config directory exists
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    echo "# OpenAI Engine Custom Configuration" > "$save_path"
    echo "OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> "$save_path"
    echo "OPENAI_MODEL=\"$OPENAI_MODEL\"" >> "$save_path"
    echo "OPENAI_ASSISTANT_TYPE=\"$OPENAI_ASSISTANT_TYPE\"" >> "$save_path"
    echo "OPENAI_INITIAL_INSTRUCTION=\"$OPENAI_INITIAL_INSTRUCTION\"" >> "$save_path"
    echo "OPENAI_MAX_PROMPT_LENGTH=$OPENAI_MAX_PROMPT_LENGTH" >> "$save_path"
    echo "OPENAI_CACHE_TOKENS=$OPENAI_CACHE_TOKENS" >> "$save_path"
    echo "OPENAI_MAX_PROMPT_PRECISION=$OPENAI_MAX_PROMPT_PRECISION" >> "$save_path"
    echo "OPENAI_DYNAMIC_PROMPT_LENGTH=$OPENAI_DYNAMIC_PROMPT_LENGTH" >> "$save_path"
    echo "OPENAI_DYNAMIC_PROMPT_LENGTH_SCALE=$OPENAI_DYNAMIC_PROMPT_LENGTH_SCALE" >> "$save_path"
    echo "OPENAI_TIMEOUT_SECONDS=$OPENAI_TIMEOUT_SECONDS" >> "$save_path"
    echo "OPENAI_SAVE_DIRECTORY=\"$OPENAI_SAVE_DIRECTORY\"" >> "$save_path"
    echo "OPENAI_COMMAND_CAPTURE_ENABLED=$OPENAI_COMMAND_CAPTURE_ENABLED" >> "$save_path"
    
    echo "Configuration saved to $save_path"
}

# Toggle command capture
function openai_toggle_command_capture() {
    OPENAI_COMMAND_CAPTURE_ENABLED=$((! $OPENAI_COMMAND_CAPTURE_ENABLED))
    echo "Command capture: $OPENAI_COMMAND_CAPTURE_ENABLED"
}

# Setup command capture hooks
autoload -Uz add-zsh-hook
function openai_preexec_hook() {
    if [[ $OPENAI_COMMAND_CAPTURE_ENABLED == true ]]; then
        # Skip commands related to the aihelp itself
        if [[ "$1" != *"openai_aihelp"* && "$1" != *"aihelp"* ]]; then
            OPENAI_LAST_COMMAND="$1"
            OPENAI_LAST_OUTPUT=""
        fi
    fi
}

function openai_precmd_hook() {
    if [[ $OPENAI_COMMAND_CAPTURE_ENABLED == true && -n "$OPENAI_LAST_COMMAND" ]]; then
        # Try to capture some of the recent output if available
        OPENAI_LAST_OUTPUT=$(fc -ln -1 -1 | tail -n 20 2>/dev/null)
    fi
}

# Add the hooks only if not already added
if [[ -z "$OPENAI_HOOKS_ADDED" ]]; then
    add-zsh-hook preexec openai_preexec_hook
    add-zsh-hook precmd openai_precmd_hook
    OPENAI_HOOKS_ADDED=true
fi

# Aliases
alias oai_chat="openai_chat"
alias oai_key="openai_set_api_key"
alias oai_model="openai_set_model"
alias oai_type="openai_set_assistant_type"
alias oai_inst="openai_set_instruction"
alias oai_file="openai_add_file"
alias oai_clear="openai_clear_files"
alias oai_test="openai_test_api_key"
alias oai_dir="openai_set_save_directory"
alias aihelp="openai_aihelp"
alias captcmd="openai_capture_command"
alias oai_toggle_capture="openai_toggle_command_capture"
alias oai_save_config="openai_save_config"

