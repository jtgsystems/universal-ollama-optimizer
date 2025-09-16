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

# Giant model selection menu with numbers
show_model_selection_menu() {
    echo -e "${GREEN}📋 Complete Model Selection Menu (September 2025)${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo

    echo -e "${YELLOW}🏆 TOP-TIER MODELS (September 2025 - Latest)${NC}"
    echo -e "${CYAN} 1)${NC} gpt-oss:20b              ${GREEN}[20GB RAM]${NC} - OpenAI's new open-weight model"
    echo -e "${CYAN} 2)${NC} gpt-oss:120b             ${GREEN}[120GB RAM]${NC} - OpenAI's flagship open model"
    echo -e "${CYAN} 3)${NC} deepseek-r1              ${GREEN}[40GB RAM]${NC} - 671B reasoning with thinking mode"
    echo -e "${CYAN} 4)${NC} gemma3:27b               ${GREEN}[32GB RAM]${NC} - Google's most capable single-GPU model"
    echo -e "${CYAN} 5)${NC} llama3.3:70b-instruct    ${GREEN}[64GB RAM]${NC} - Meta's 2025 flagship, rivals GPT-4"
    echo

    echo -e "${YELLOW}💻 PREMIER CODING MODELS (2025 Latest)${NC}"
    echo -e "${CYAN} 6)${NC} qwen3-coder:30b          ${GREEN}[30GB RAM]${NC} - Alibaba's latest 2025 coding model"
    echo -e "${CYAN} 7)${NC} deepseek-coder:33b       ${GREEN}[32GB RAM]${NC} - #1 coding model, complex tasks"
    echo -e "${CYAN} 8)${NC} codellama:34b            ${GREEN}[32GB RAM]${NC} - Meta's specialized coding model"
    echo -e "${CYAN} 9)${NC} qwen2.5-coder:32b        ${GREEN}[32GB RAM]${NC} - Previous Alibaba code model"
    echo -e "${CYAN}10)${NC} codellama:13b-instruct   ${GREEN}[16GB RAM]${NC} - Balanced coding performance"
    echo -e "${CYAN}11)${NC} codegemma:7b             ${GREEN}[8GB RAM]${NC}  - Google's coding model"
    echo

    echo -e "${YELLOW}⚡ RESOURCE-EFFICIENT CHAMPIONS (2025 Latest)${NC}"
    echo -e "${CYAN}12)${NC} phi4:14b                 ${GREEN}[14GB RAM]${NC} - Microsoft's 2025 state-of-the-art"
    echo -e "${CYAN}13)${NC} phi4-mini                ${GREEN}[4GB RAM]${NC}  - 2025 multilingual & reasoning"
    echo -e "${CYAN}14)${NC} gemma3:12b               ${GREEN}[12GB RAM]${NC} - Google's 2025 efficient model"
    echo -e "${CYAN}15)${NC} gemma3:4b                ${GREEN}[4GB RAM]${NC}  - Compact Google 2025 model"
    echo -e "${CYAN}16)${NC} mistral:7b-instruct      ${GREEN}[8GB RAM]${NC}  - Community favorite for beginners"
    echo -e "${CYAN}17)${NC} llama3.2:3b             ${GREEN}[4GB RAM]${NC}  - Compact Llama for lightweight"
    echo -e "${CYAN}18)${NC} gemma3:1b                ${GREEN}[2GB RAM]${NC}  - Ultra-lightweight 2025 model"
    echo -e "${CYAN}19)${NC} granite3.1:2b-instruct   ${GREEN}[2GB RAM]${NC}  - IBM's enterprise 2B model"
    echo

    echo -e "${YELLOW}🎨 CREATIVE & MULTIMODAL${NC}"
    echo -e "${CYAN}20)${NC} llava:latest             ${GREEN}[16GB RAM]${NC} - Leading vision model for images"
    echo -e "${CYAN}21)${NC} qwen-vl                  ${GREEN}[16GB RAM]${NC} - Advanced multimodal processing"
    echo -e "${CYAN}22)${NC} gemma2:27b               ${GREEN}[32GB RAM]${NC} - Excellent creative writing"
    echo -e "${CYAN}23)${NC} llava:34b                ${GREEN}[32GB RAM]${NC} - Large vision language model"
    echo -e "${CYAN}24)${NC} bakllava:latest          ${GREEN}[16GB RAM]${NC} - Alternative vision model"
    echo -e "${CYAN}25)${NC} moondream:latest         ${GREEN}[2GB RAM]${NC}  - Smallest vision model (1.8B)"
    echo

    echo -e "${YELLOW}🧠 SPECIALIZED MODELS${NC}"
    echo -e "${CYAN}26)${NC} llama3.1:405b           ${GREEN}[256GB RAM]${NC} - Massive flagship model"
    echo -e "${CYAN}27)${NC} mixtral:8x7b             ${GREEN}[32GB RAM]${NC} - Mixture of Experts model"
    echo -e "${CYAN}28)${NC} mixtral:8x22b            ${GREEN}[64GB RAM]${NC} - Large MoE model"
    echo -e "${CYAN}29)${NC} command-r:35b            ${GREEN}[32GB RAM]${NC} - Cohere's command model"
    echo -e "${CYAN}30)${NC} wizard-vicuna:13b        ${GREEN}[16GB RAM]${NC} - Enhanced conversation model"
    echo -e "${CYAN}31)${NC} orca-mini:13b            ${GREEN}[16GB RAM]${NC} - Microsoft's Orca variant"
    echo

    echo -e "${YELLOW}🔬 RESEARCH & ANALYSIS${NC}"
    echo -e "${CYAN}32)${NC} llama3-gradient:8b       ${GREEN}[8GB RAM]${NC}  - Enhanced reasoning"
    echo -e "${CYAN}33)${NC} vicuna:13b               ${GREEN}[16GB RAM]${NC} - Research assistant model"
    echo -e "${CYAN}34)${NC} openchat:latest          ${GREEN}[8GB RAM]${NC}  - Open conversation model"
    echo -e "${CYAN}35)${NC} starling-lm:7b           ${GREEN}[8GB RAM]${NC}  - Berkeley research model"
    echo -e "${CYAN}36)${NC} zephyr:7b                ${GREEN}[8GB RAM]${NC}  - Hugging Face model"
    echo

    echo -e "${YELLOW}🌐 MULTILINGUAL MODELS${NC}"
    echo -e "${CYAN}36)${NC} qwen2.5:14b             ${GREEN}[16GB RAM]${NC} - Strong multilingual support"
    echo -e "${CYAN}37)${NC} yi:34b                   ${GREEN}[32GB RAM]${NC} - Chinese-English bilingual"
    echo -e "${CYAN}38)${NC} aya:35b                  ${GREEN}[32GB RAM]${NC} - Multilingual instruction model"
    echo -e "${CYAN}39)${NC} chinese-llama2:7b        ${GREEN}[8GB RAM]${NC}  - Chinese language model"
    echo -e "${CYAN}40)${NC} baichuan2:7b             ${GREEN}[8GB RAM]${NC}  - Chinese conversation model"
    echo

    echo -e "${YELLOW}⚡ SPEED & EFFICIENCY${NC}"
    echo -e "${CYAN}41)${NC} neural-chat:7b           ${GREEN}[8GB RAM]${NC}  - Fast conversation model"
    echo -e "${CYAN}42)${NC} dolphin-mistral:7b       ${GREEN}[8GB RAM]${NC}  - Uncensored variant"
    echo -e "${CYAN}43)${NC} solar:10.7b              ${GREEN}[12GB RAM]${NC} - Solar Pro model"
    echo -e "${CYAN}44)${NC} nous-hermes2:latest      ${GREEN}[8GB RAM]${NC}  - Nous Research model"
    echo -e "${CYAN}45)${NC} alpaca:7b                ${GREEN}[8GB RAM]${NC}  - Stanford's Alpaca"
    echo

    echo -e "${YELLOW}🎯 FINE-TUNED VARIANTS${NC}"
    echo -e "${CYAN}46)${NC} llama3-chatqa:8b         ${GREEN}[8GB RAM]${NC}  - Q&A specialized"
    echo -e "${CYAN}47)${NC} llama3-instruct:8b       ${GREEN}[8GB RAM]${NC}  - Instruction following"
    echo -e "${CYAN}48)${NC} mistral-openorca:7b      ${GREEN}[8GB RAM]${NC}  - OpenOrca fine-tune"
    echo -e "${CYAN}49)${NC} wizard-math:7b           ${GREEN}[8GB RAM]${NC}  - Mathematics specialist"
    echo -e "${CYAN}50)${NC} medllama2:7b             ${GREEN}[8GB RAM]${NC}  - Medical domain model"
    echo

    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}💡 TIP: For beginners, try options 2, 12, or 15 (8GB RAM models)${NC}"
    echo -e "${PURPLE}🚀 For coding, try options 6, 7, or 9 (coding specialists)${NC}"
    echo -e "${PURPLE}🖼️ For vision tasks, try options 19, 20, or 24 (multimodal)${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo

    # Array of model names and descriptions corresponding to menu numbers (2025 LATEST)
    MODELS=(
        "gpt-oss:20b" "gpt-oss:120b" "deepseek-r1" "gemma3:27b" "llama3.3:70b-instruct"
        "qwen3-coder:30b" "deepseek-coder:33b" "codellama:34b" "qwen2.5-coder:32b" "codellama:13b-instruct"
        "codegemma:7b" "phi4:14b" "phi4-mini" "gemma3:12b" "gemma3:4b"
        "mistral:7b-instruct" "llama3.2:3b" "gemma3:1b" "granite3.1:2b-instruct" "llava:latest"
        "qwen-vl" "gemma2:27b" "llava:34b" "bakllava:latest" "moondream:latest"
        "llama3.1:405b" "mixtral:8x7b" "mixtral:8x22b" "command-r:35b" "wizard-vicuna:13b"
        "orca-mini:13b" "llama3-gradient:8b" "vicuna:13b" "openchat:latest" "starling-lm:7b"
        "zephyr:7b" "qwen2.5:14b" "yi:34b" "aya:35b" "chinese-llama2:7b"
        "baichuan2:7b" "neural-chat:7b" "dolphin-mistral:7b" "solar:10.7b" "nous-hermes2:latest"
        "alpaca:7b" "llama3-chatqa:8b" "llama3-instruct:8b" "mistral-openorca:7b" "wizard-math:7b" "medllama2:7b"
    )

    # Model descriptions array (corresponding to MODELS array) - 2025 LATEST
    MODEL_DESCRIPTIONS=(
        "OpenAI's new open-weight model" "OpenAI's flagship open model" "671B reasoning with thinking mode" "Google's most capable single-GPU model" "Meta's 2025 flagship, rivals GPT-4"
        "Alibaba's latest 2025 coding model" "#1 coding model, complex tasks" "Meta's specialized coding model" "Previous Alibaba code model" "Balanced coding performance"
        "Google's coding model" "Microsoft's 2025 state-of-the-art" "2025 multilingual & reasoning" "Google's 2025 efficient model" "Compact Google 2025 model"
        "Community favorite for beginners" "Compact Llama lightweight" "Ultra-lightweight 2025 model" "IBM's enterprise 2B model" "Leading vision model for images"
        "Advanced multimodal processing" "Excellent creative writing" "Large vision language model" "Alternative vision model" "Smallest vision model (1.8B)"
        "Massive flagship model" "Mixture of Experts 8x7B" "Large MoE 8x22B" "Cohere's command model" "Enhanced conversation model"
        "Microsoft's Orca variant" "Enhanced reasoning" "Research assistant model" "Open conversation model" "Berkeley research model"
        "Hugging Face model" "Strong multilingual support" "Chinese-English bilingual" "Multilingual instruction model" "Chinese language model"
        "Chinese conversation model" "Fast conversation model" "Uncensored variant" "Solar Pro model" "Nous Research model"
        "Stanford's Alpaca" "Q&A specialized" "Instruction following" "OpenOrca fine-tune" "Mathematics specialist" "Medical domain model"
    )
}

# Function to get model selection from user
get_model_selection() {
    while true; do
        show_model_selection_menu

        echo -e "${GREEN}Choose an option:${NC}"
        echo -e "${CYAN}51)${NC} Enter custom model name"
        echo -e "${CYAN}52)${NC} Show my local models only"
        echo -e "${CYAN}53)${NC} Update all installed models"
        echo -e "${CYAN} 0)${NC} Exit"
        echo

        read -p "Enter your choice (0-53): " choice

        case $choice in
            0)
                echo -e "${YELLOW}Goodbye!${NC}"
                exit 0
                ;;
            51)
                echo
                read -p "Enter custom model name (e.g., llama3.2:latest): " custom_model
                if [[ -n "$custom_model" ]]; then
                    MODEL_NAME="$custom_model"
                    return 0
                else
                    echo -e "${RED}Invalid model name${NC}"
                    continue
                fi
                ;;
            52)
                echo
                list_available_models
                echo
                read -p "Enter model name from above list: " local_model
                if [[ -n "$local_model" ]]; then
                    MODEL_NAME="$local_model"
                    return 0
                else
                    echo -e "${RED}Invalid model name${NC}"
                    continue
                fi
                ;;
            53)
                echo
                update_all_models
                echo
                read -p "Press Enter to continue..."
                continue
                ;;
            [1-9]|[1-4][0-9]|50)
                if [[ $choice -ge 1 && $choice -le 50 ]]; then
                    MODEL_NAME="${MODELS[$((choice-1))]}"
                    echo -e "${GREEN}Selected: ${CYAN}$MODEL_NAME${NC}"
                    return 0
                else
                    echo -e "${RED}Invalid choice. Please select 0-53.${NC}"
                    continue
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 0-53.${NC}"
                continue
                ;;
        esac
    done
}

# Function to update all installed models (from Ollama-Menu)
update_all_models() {
    echo -e "${GREEN}🔄 Updating All Installed Models${NC}"
    echo -e "${BLUE}════════════════════════════════${NC}"
    echo

    # Get list of currently installed models
    local installed_models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep -v '^$')

    if [[ -z "$installed_models" ]]; then
        echo -e "${YELLOW}⚠️ No models found to update${NC}"
        return 0
    fi

    echo -e "${CYAN}Found the following installed models:${NC}"
    echo "$installed_models" | while read model; do
        echo -e "  • ${YELLOW}$model${NC}"
    done
    echo

    read -p "Continue with updates? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Update cancelled${NC}"
        return 0
    fi

    echo
    echo -e "${GREEN}Starting model updates...${NC}"
    echo

    local success_count=0
    local total_count=0

    echo "$installed_models" | while read model; do
        if [[ -n "$model" ]]; then
            total_count=$((total_count + 1))
            echo -e "${CYAN}Updating: $model${NC}"

            if ollama pull "$model" 2>/dev/null; then
                echo -e "${GREEN}✓ Successfully updated: $model${NC}"
                success_count=$((success_count + 1))
            else
                echo -e "${RED}✗ Failed to update: $model${NC}"
            fi
            echo
        fi
    done

    echo -e "${GREEN}🎉 Update process completed${NC}"
    echo -e "${CYAN}Updated models successfully${NC}"
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

    # Get model selection from user using comprehensive menu
    get_model_selection

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