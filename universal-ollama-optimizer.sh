#!/bin/bash
# Universal Ollama Optimizer - Terminal Interface
# 🚀 Professional toolkit for launching and optimizing Ollama AI models
#
# Developed by JTGSYSTEMS.COM | JointTechnologyGroup.com
# Repository: https://github.com/your-username/universal-ollama-optimizer
#
# Features: Universal model support, optimization profiles, system monitoring,
# intelligent caching, and automated configuration management

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration file path
CONFIG_FILE="$HOME/.config/universal-ollama-optimizer/config.conf"

# Default configuration values
DEFAULT_PROFILE="balanced"
AUTO_START_OLLAMA=true
SUGGESTED_MODELS="llama3.2:latest,mistral:7b,gemma2:9b,codellama:13b"
SHOW_SYSTEM_INFO=true
SHOW_GPU_INFO=true
DOWNLOAD_TIMEOUT=1800
MIN_DISK_SPACE_GB=5
SHOW_COLORS=true
SHOW_BANNER=true

# Load configuration file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Source config file safely
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^[[:space:]]*# ]] && continue
            [[ -z $key ]] && continue

            # Remove quotes and whitespace
            key=$(echo "$key" | tr -d '[:space:]')
            value=$(echo "$value" | sed 's/^["'\'']\|["'\'']$//g' | tr -d '[:space:]')

            # Set variables based on config
            case "$key" in
                DEFAULT_PROFILE) DEFAULT_PROFILE="$value" ;;
                AUTO_START_OLLAMA) AUTO_START_OLLAMA="$value" ;;
                SUGGESTED_MODELS) SUGGESTED_MODELS="$value" ;;
                SHOW_SYSTEM_INFO) SHOW_SYSTEM_INFO="$value" ;;
                SHOW_GPU_INFO) SHOW_GPU_INFO="$value" ;;
                DOWNLOAD_TIMEOUT) DOWNLOAD_TIMEOUT="$value" ;;
                MIN_DISK_SPACE_GB) MIN_DISK_SPACE_GB="$value" ;;
                SHOW_COLORS) SHOW_COLORS="$value" ;;
                SHOW_BANNER) SHOW_BANNER="$value" ;;
            esac
        done < "$CONFIG_FILE"
    fi
}

# Configuration profiles for different use cases
declare -A PROFILES=(
    ["balanced"]="temperature 0.5, top_p 0.85, top_k 30, repeat_penalty 1.08"
    ["technical"]="temperature 0.2, top_p 0.8, top_k 20, repeat_penalty 1.05"
    ["creative"]="temperature 1.0, top_p 0.95, top_k 50, repeat_penalty 1.15"
    ["code"]="temperature 0.15, top_p 0.7, top_k 15, repeat_penalty 1.02"
    ["reasoning"]="temperature 0.3, top_p 0.75, top_k 25, repeat_penalty 1.03"
    ["roleplay"]="temperature 0.8, top_p 0.9, top_k 40, repeat_penalty 1.12"
)

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         Universal Ollama Optimizer        ║${NC}"
    echo -e "${BLUE}║      JTGSYSTEMS.COM | JointTechnologyGroup ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo
}

# Function to check if ollama is running
check_ollama_service() {
    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}✗ Ollama not found. Please install Ollama first.${NC}"
        echo -e "${YELLOW}Visit: https://ollama.ai/download${NC}"
        exit 1
    fi

    # Check if ollama service is running
    if ! pgrep -x "ollama" > /dev/null; then
        echo -e "${YELLOW}Starting Ollama service...${NC}"

        # Try to start ollama service
        ollama serve > /dev/null 2>&1 &
        OLLAMA_PID=$!

        # Give it a moment to start
        sleep 2

        # Check if the process is still running
        if ! kill -0 $OLLAMA_PID 2>/dev/null; then
            echo -e "${RED}✗ Failed to start Ollama service. Permission denied or port conflict.${NC}"
            echo -e "${YELLOW}Try: sudo ollama serve or check if port 11434 is in use${NC}"
            exit 1
        fi

        # Wait for service to start with timeout
        local count=0
        while [[ $count -lt 10 ]] && ! pgrep -x "ollama" > /dev/null; do
            sleep 1
            ((count++))
        done

        if ! pgrep -x "ollama" > /dev/null; then
            echo -e "${RED}✗ Ollama service failed to start after 10 seconds${NC}"
            echo -e "${YELLOW}Check logs: journalctl -u ollama -n 20${NC}"
            exit 1
        fi
    fi

    # Verify ollama API is responding
    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${RED}✗ Ollama API not responding on port 11434${NC}"
        echo -e "${YELLOW}Check if another service is using port 11434${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Ollama service is running${NC}"
}

# Function to list available models
list_available_models() {
    echo -e "\n${GREEN}Available Local Models:${NC}"
    if ollama list 2>/dev/null | grep -q ":"; then
        ollama list | tail -n +2 | while read line; do
            if [[ -n "$line" ]]; then
                model_name=$(echo "$line" | awk '{print $1}')
                model_size=$(echo "$line" | awk '{print $2}')
                echo -e "  ${CYAN}• $model_name${NC} ($model_size)"
            fi
        done
    else
        echo -e "  ${YELLOW}No models found locally${NC}"
    fi
    echo
}

# Function to suggest popular models
suggest_popular_models() {
    echo -e "${GREEN}Popular Models to Try:${NC}"
    echo -e "  ${CYAN}• llama3.2:latest${NC}     - Latest Llama model (general purpose)"
    echo -e "  ${CYAN}• codellama:latest${NC}    - Code generation specialist"
    echo -e "  ${CYAN}• mistral:latest${NC}      - Fast and efficient"
    echo -e "  ${CYAN}• phi3:latest${NC}         - Lightweight but capable"
    echo -e "  ${CYAN}• gemma2:latest${NC}       - Google's Gemma model"
    echo -e "  ${CYAN}• qwen2.5:latest${NC}      - Excellent reasoning"
    echo -e "  ${CYAN}• deepseek-coder:latest${NC} - Advanced coding model"
    echo
}

# Function to validate model name
validate_model() {
    local model_name="$1"

    # Validate input
    if [[ -z "$model_name" ]]; then
        echo -e "${RED}✗ Model name cannot be empty${NC}"
        return 1
    fi

    # Check for valid model name format
    if [[ ! "$model_name" =~ ^[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+$ ]] && [[ ! "$model_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo -e "${YELLOW}⚠ Model name format: 'model:tag' (e.g., llama3.2:latest)${NC}"
    fi

    # Check if model exists locally
    if ollama list 2>/dev/null | grep -q "^$model_name"; then
        return 0
    fi

    # Check available disk space before download
    local available_gb=$(df /tmp | awk 'NR==2{printf "%.1f", $4/1024/1024}')
    if (( $(echo "$available_gb < 5" | bc -l) )); then
        echo -e "${RED}✗ Insufficient disk space: ${available_gb}GB available (5GB+ recommended)${NC}"
        return 1
    fi

    # If not local, offer to pull it
    echo -e "${YELLOW}Model '$model_name' not found locally.${NC}"
    echo -e "${CYAN}Available disk space: ${available_gb}GB${NC}"
    read -p "Would you like to download it? (y/n): " download_choice

    if [[ "$download_choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Downloading $model_name...${NC}"
        echo -e "${CYAN}This may take several minutes depending on model size${NC}"

        # Create a timeout for download
        if timeout 1800 ollama pull "$model_name" 2>&1; then
            echo -e "${GREEN}✓ Model downloaded successfully${NC}"
            return 0
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                echo -e "${RED}✗ Download timed out after 30 minutes${NC}"
            else
                echo -e "${RED}✗ Failed to download model (exit code: $exit_code)${NC}"
            fi
            echo -e "${YELLOW}Possible issues: network connection, model not found, insufficient space${NC}"
            return 1
        fi
    else
        return 1
    fi
}

# Function to get model info
get_model_info() {
    local model_name="$1"

    echo -e "${GREEN}Model Information:${NC}"

    # Try to get model info from ollama
    if ollama show "$model_name" > /dev/null 2>&1; then
        local model_info=$(ollama show "$model_name" 2>/dev/null)

        # Extract basic info
        echo -e "  • Model: ${CYAN}$model_name${NC}"

        # Try to get size info
        local size_info=$(ollama list | grep "^$model_name" | awk '{print $2}')
        if [[ -n "$size_info" ]]; then
            echo -e "  • Size: ${CYAN}$size_info${NC}"
        fi

        # Get model family info if available
        if echo "$model_info" | grep -q "parameters"; then
            local params=$(echo "$model_info" | grep -i "parameters" | head -1)
            echo -e "  • Info: ${CYAN}$params${NC}"
        fi
    else
        echo -e "  • Model: ${CYAN}$model_name${NC}"
        echo -e "  • Status: ${YELLOW}Ready to launch${NC}"
    fi
}

# Function to check system resources
check_system_resources() {
    echo -e "\n${GREEN}System Status:${NC}"

    # Check GPU
    if command -v nvidia-smi &> /dev/null; then
        GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [[ -n "$GPU_MEM" ]]; then
            echo -e "  • GPU Memory: ${CYAN}$GPU_MEM MB${NC}"
        fi
    fi

    # Check system RAM
    SYS_MEM=$(free -g | awk '/^Mem:/{print $2}')
    echo -e "  • System RAM: ${CYAN}${SYS_MEM}GB${NC}"

    # Check available disk space
    DISK_SPACE=$(df -h ~ | awk 'NR==2{print $4}')
    echo -e "  • Available Disk: ${CYAN}$DISK_SPACE${NC}"
}

# Function to show profile selection
show_profile_selection() {
    echo -e "\n${GREEN}Optimization Profiles:${NC}"
    echo -e "  ${CYAN}1)${NC} Balanced          - General purpose (temp: 0.5)"
    echo -e "  ${CYAN}2)${NC} Technical/Factual - Precise answers (temp: 0.2)"
    echo -e "  ${CYAN}3)${NC} Creative Writing  - Imaginative content (temp: 1.0)"
    echo -e "  ${CYAN}4)${NC} Code Generation   - Programming tasks (temp: 0.15)"
    echo -e "  ${CYAN}5)${NC} Reasoning/Logic   - Problem solving (temp: 0.3)"
    echo -e "  ${CYAN}6)${NC} Roleplay/Chat     - Conversational (temp: 0.8)"
    echo -e "  ${CYAN}7)${NC} Custom Parameters - Manual configuration"
    echo -e "  ${CYAN}8)${NC} Create Modelfile  - Save custom config"
    echo -e "  ${CYAN}9)${NC} Raw Mode          - No parameter changes"
    echo
}

# Function to handle custom parameters
handle_custom_parameters() {
    echo -e "\n${YELLOW}Custom Parameter Configuration:${NC}"
    read -p "Temperature (0.0-2.0, default 0.8): " temp
    read -p "Top-p (0.0-1.0, default 0.9): " top_p
    read -p "Top-k (1-100, default 40): " top_k
    read -p "Context length (default model max): " num_ctx
    read -p "Max tokens per response (default 2048): " num_predict
    read -p "Repeat penalty (1.0-1.3, default 1.1): " repeat_penalty

    temp=${temp:-0.8}
    top_p=${top_p:-0.9}
    top_k=${top_k:-40}
    num_ctx=${num_ctx:-}
    num_predict=${num_predict:-2048}
    repeat_penalty=${repeat_penalty:-1.1}

    CUSTOM_PARAMS="temperature $temp, top_p $top_p, top_k $top_k, repeat_penalty $repeat_penalty"
    if [[ -n "$num_ctx" ]]; then
        CUSTOM_PARAMS="$CUSTOM_PARAMS, num_ctx $num_ctx"
    fi
    CUSTOM_PARAMS="$CUSTOM_PARAMS, num_predict $num_predict"

    echo "$CUSTOM_PARAMS"
}

# Function to create custom modelfile
create_custom_modelfile() {
    local base_model="$1"

    echo -e "\n${YELLOW}Creating Custom Modelfile...${NC}"
    read -p "Custom model name (e.g., ${base_model}-custom): " model_name
    model_name=${model_name:-"${base_model}-custom"}

    echo -e "\n${YELLOW}Select base configuration:${NC}"
    echo -e "  ${CYAN}1)${NC} Balanced"
    echo -e "  ${CYAN}2)${NC} Technical"
    echo -e "  ${CYAN}3)${NC} Creative"
    echo -e "  ${CYAN}4)${NC} Code-focused"
    echo -e "  ${CYAN}5)${NC} Custom"

    read -p "Select base [1-5]: " base_choice

    case $base_choice in
        1) TEMPLATE_PARAMS="${PROFILES[balanced]}" ;;
        2) TEMPLATE_PARAMS="${PROFILES[technical]}" ;;
        3) TEMPLATE_PARAMS="${PROFILES[creative]}" ;;
        4) TEMPLATE_PARAMS="${PROFILES[code]}" ;;
        5) TEMPLATE_PARAMS=$(handle_custom_parameters) ;;
        *) TEMPLATE_PARAMS="${PROFILES[balanced]}" ;;
    esac

    read -p "System prompt (optional): " system_prompt
    system_prompt=${system_prompt:-"You are a helpful AI assistant."}

    # Create Modelfile
    cat > /tmp/Modelfile << EOF
FROM $base_model

# Optimized parameters
$(echo "$TEMPLATE_PARAMS" | sed 's/, /\nPARAMETER /g' | sed 's/^/PARAMETER /')

# System configuration
SYSTEM "$system_prompt"
EOF

    echo -e "${GREEN}Creating model '$model_name'...${NC}"
    if ollama create "$model_name" -f /tmp/Modelfile; then
        echo -e "${GREEN}✓ Custom model '$model_name' created successfully!${NC}"
        read -p "Launch this custom model now? (y/n): " run_custom
        if [[ "$run_custom" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Starting $model_name...${NC}"
            ollama run "$model_name"
            exit 0
        fi
    else
        echo -e "${RED}✗ Failed to create custom model${NC}"
    fi

    rm -f /tmp/Modelfile
}

# Function to display parameter instructions
show_parameter_instructions() {
    local params="$1"
    local profile_name="$2"

    if [[ "$profile_name" != "Raw Mode" ]]; then
        echo -e "\n${GREEN}Selected Profile: ${CYAN}$profile_name${NC}"
        echo -e "${GREEN}Recommended Settings:${NC} $params"
        echo
        echo -e "${YELLOW}To apply these settings in the chat, use:${NC}"

        # Parse and display individual set commands
        IFS=', ' read -ra PARAM_ARRAY <<< "$params"
        for param in "${PARAM_ARRAY[@]}"; do
            if [[ $param == *" "* ]]; then
                param_name=$(echo $param | cut -d' ' -f1)
                param_value=$(echo $param | cut -d' ' -f2-)
                echo -e "  ${CYAN}/set parameter $param_name $param_value${NC}"
            fi
        done

        echo
    fi

    echo -e "${YELLOW}Available Runtime Commands:${NC}"
    echo -e "  • ${PURPLE}/set parameter <name> <value>${NC} - Adjust parameters"
    echo -e "  • ${PURPLE}/set system <prompt>${NC}          - Change system prompt"
    echo -e "  • ${PURPLE}/show parameters${NC}              - View current settings"
    echo -e "  • ${PURPLE}/show info${NC}                    - Model information"
    echo -e "  • ${PURPLE}/save <name>${NC}                  - Save conversation"
    echo -e "  • ${PURPLE}/load <name>${NC}                  - Load conversation"
    echo -e "  • ${PURPLE}/help${NC}                         - Show all commands"
    echo
    echo -e "${YELLOW}Tip:${NC} Type 'reasoning: <level>' in your prompts for different thinking depths"
    echo -e "      (levels: brief, detailed, thorough)"
    echo
}

# Main execution
main() {
    # Load configuration first
    load_config

    # Show header if enabled
    if [[ "$SHOW_BANNER" == "true" ]]; then
        show_header
    fi

    # Check Ollama service if auto-start enabled
    if [[ "$AUTO_START_OLLAMA" == "true" ]]; then
        check_ollama_service
    fi

    echo
    list_available_models
    suggest_popular_models

    # Get model name from user
    read -p "Enter model name (with tag, e.g., llama3.2:latest): " MODEL_NAME

    if [[ -z "$MODEL_NAME" ]]; then
        echo -e "${RED}No model name provided. Exiting.${NC}"
        exit 1
    fi

    # Validate and potentially download model
    if ! validate_model "$MODEL_NAME"; then
        echo -e "${RED}Cannot proceed without a valid model. Exiting.${NC}"
        exit 1
    fi

    show_header
    get_model_info "$MODEL_NAME"
    check_system_resources
    show_profile_selection

    read -p "Select profile [1-9] (default: 1): " choice
    choice=${choice:-1}

    case $choice in
        1)
            SELECTED_PROFILE="Balanced"
            PARAMS="${PROFILES[balanced]}"
            ;;
        2)
            SELECTED_PROFILE="Technical/Factual"
            PARAMS="${PROFILES[technical]}"
            ;;
        3)
            SELECTED_PROFILE="Creative Writing"
            PARAMS="${PROFILES[creative]}"
            ;;
        4)
            SELECTED_PROFILE="Code Generation"
            PARAMS="${PROFILES[code]}"
            ;;
        5)
            SELECTED_PROFILE="Reasoning/Logic"
            PARAMS="${PROFILES[reasoning]}"
            ;;
        6)
            SELECTED_PROFILE="Roleplay/Chat"
            PARAMS="${PROFILES[roleplay]}"
            ;;
        7)
            SELECTED_PROFILE="Custom"
            PARAMS=$(handle_custom_parameters)
            ;;
        8)
            create_custom_modelfile "$MODEL_NAME"
            return
            ;;
        9)
            SELECTED_PROFILE="Raw Mode"
            PARAMS=""
            ;;
        *)
            SELECTED_PROFILE="Balanced"
            PARAMS="${PROFILES[balanced]}"
            ;;
    esac

    show_parameter_instructions "$PARAMS" "$SELECTED_PROFILE"

    echo -e "${GREEN}Starting $MODEL_NAME...${NC}"
    echo -e "${CYAN}Press Ctrl+C to exit${NC}"
    echo

    # Launch the model
    ollama run "$MODEL_NAME"
}

# Run main function
main "$@"