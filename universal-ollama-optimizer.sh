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

# ===============================================
# 🛡️ COMPREHENSIVE ERROR HANDLING SYSTEM
# ===============================================

# Error logging and reporting system
ERROR_LOG="$HOME/.config/universal-ollama-optimizer/errors.log"
DEBUG_MODE=false

# Ensure log directory exists
mkdir -p "$(dirname "$ERROR_LOG")"

# Error logging function
log_error() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$ERROR_LOG"

    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo -e "${RED}[DEBUG] [$level] $message${NC}" >&2
    fi
}

# Comprehensive system validation
validate_system() {
    local errors=0

    # Check operating system
    if [[ "$OSTYPE" != "linux"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}✗ Unsupported operating system: $OSTYPE${NC}"
        echo -e "${YELLOW}This script supports Linux and macOS only${NC}"
        log_error "ERROR" "Unsupported OS: $OSTYPE"
        ((errors++))
    fi

    # Check bash version
    if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
        echo -e "${RED}✗ Bash version too old: $BASH_VERSION${NC}"
        echo -e "${YELLOW}Bash 4.0+ required. Please upgrade bash${NC}"
        log_error "ERROR" "Bash version too old: $BASH_VERSION"
        ((errors++))
    fi

    # Check required commands
    local required_commands=("curl" "wget" "ps" "kill" "pgrep")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}✗ Required command missing: $cmd${NC}"
            echo -e "${YELLOW}Please install $cmd and try again${NC}"
            log_error "ERROR" "Missing command: $cmd"
            ((errors++))
        fi
    done

    return $errors
}

# Network connectivity validation
validate_network() {
    local test_urls=("https://ollama.ai" "https://huggingface.co" "https://github.com")
    local connectivity=false

    echo -e "${CYAN}🌐 Checking network connectivity...${NC}"

    for url in "${test_urls[@]}"; do
        if curl -s --max-time 10 --head "$url" &> /dev/null; then
            connectivity=true
            break
        fi
    done

    if [[ "$connectivity" == "false" ]]; then
        echo -e "${RED}✗ Network connectivity issues detected${NC}"
        echo -e "${YELLOW}Troubleshooting steps:${NC}"
        echo -e "  1. Check internet connection"
        echo -e "  2. Verify proxy settings: echo \$HTTP_PROXY"
        echo -e "  3. Check firewall settings"
        echo -e "  4. Try: curl -v https://ollama.ai"
        log_error "ERROR" "Network connectivity failed"
        return 1
    fi

    echo -e "${GREEN}✓ Network connectivity verified${NC}"
    return 0
}

# Ollama installation and service validation
validate_ollama_installation() {
    local errors=0

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}✗ Ollama not installed${NC}"
        echo -e "${YELLOW}Installation options:${NC}"
        echo -e "  1. Quick install: curl -fsSL https://ollama.ai/install.sh | sh"
        echo -e "  2. Manual download: https://ollama.ai/download"
        echo -e "  3. Package manager: brew install ollama (macOS)"
        log_error "ERROR" "Ollama not installed"
        return 1
    fi

    # Check ollama version
    local ollama_version
    if ollama_version=$(ollama --version 2>/dev/null); then
        echo -e "${GREEN}✓ Ollama installed: $ollama_version${NC}"
        log_error "INFO" "Ollama version: $ollama_version"
    else
        echo -e "${RED}✗ Ollama installation corrupted${NC}"
        echo -e "${YELLOW}Try reinstalling Ollama${NC}"
        log_error "ERROR" "Ollama installation corrupted"
        return 1
    fi

    # Check if ollama service is running
    if ! pgrep -f "ollama serve" > /dev/null; then
        echo -e "${YELLOW}⚠ Ollama service not running${NC}"

        if [[ "$AUTO_START_OLLAMA" == "true" ]]; then
            echo -e "${CYAN}🚀 Starting Ollama service...${NC}"

            # Try to start ollama service
            if start_ollama_service; then
                echo -e "${GREEN}✓ Ollama service started successfully${NC}"
            else
                echo -e "${RED}✗ Failed to start Ollama service${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}Please start Ollama manually: ollama serve${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}✓ Ollama service is running${NC}"
    fi

    return 0
}

# Advanced Ollama service management
start_ollama_service() {
    local max_attempts=3
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        echo -e "${CYAN}Attempt $attempt/$max_attempts: Starting Ollama...${NC}"

        # Start ollama in background
        nohup ollama serve > /dev/null 2>&1 &
        local ollama_pid=$!

        # Wait for service to initialize
        sleep 3

        # Check if service is responding
        if curl -s http://localhost:11434/api/tags &> /dev/null; then
            echo -e "${GREEN}✓ Ollama service started (PID: $ollama_pid)${NC}"
            log_error "INFO" "Ollama service started successfully (PID: $ollama_pid)"
            return 0
        fi

        # Check for port conflicts
        if netstat -tuln 2>/dev/null | grep -q ":11434"; then
            echo -e "${RED}✗ Port 11434 already in use${NC}"
            echo -e "${YELLOW}Try: sudo lsof -i :11434${NC}"
            log_error "ERROR" "Port 11434 conflict"
            return 1
        fi

        ((attempt++))
        sleep 2
    done

    echo -e "${RED}✗ Failed to start Ollama after $max_attempts attempts${NC}"
    log_error "ERROR" "Failed to start Ollama service after $max_attempts attempts"
    return 1
}

# Resource validation and monitoring
validate_system_resources() {
    local warnings=0

    echo -e "${CYAN}📊 Checking system resources...${NC}"

    # Check available RAM
    local total_ram_gb
    if [[ "$OSTYPE" == "linux"* ]]; then
        total_ram_gb=$(free -g | awk 'NR==2{printf "%.0f", $2}')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        total_ram_gb=$(echo "$(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)
    fi

    if [[ $total_ram_gb -lt 8 ]]; then
        echo -e "${YELLOW}⚠ Low system RAM: ${total_ram_gb}GB (8GB+ recommended)${NC}"
        echo -e "  • Consider using smaller models (1B-3B parameters)"
        echo -e "  • Use efficient profiles (technical, code)"
        log_error "WARNING" "Low RAM: ${total_ram_gb}GB"
        ((warnings++))
    else
        echo -e "${GREEN}✓ System RAM: ${total_ram_gb}GB${NC}"
    fi

    # Check available disk space
    local available_space_gb
    available_space_gb=$(df "$HOME" | awk 'NR==2 {printf "%.0f", $4/1024/1024}')

    if [[ $available_space_gb -lt $MIN_DISK_SPACE_GB ]]; then
        echo -e "${RED}✗ Insufficient disk space: ${available_space_gb}GB${NC}"
        echo -e "${YELLOW}At least ${MIN_DISK_SPACE_GB}GB required for model downloads${NC}"
        echo -e "  • Clean up space: rm -rf ~/.ollama/models/blobs/*"
        echo -e "  • Remove unused models: ollama rm <model_name>"
        log_error "ERROR" "Insufficient disk space: ${available_space_gb}GB"
        return 1
    else
        echo -e "${GREEN}✓ Available disk space: ${available_space_gb}GB${NC}"
    fi

    # Check GPU availability (optional)
    if command -v nvidia-smi &> /dev/null; then
        if nvidia-smi &> /dev/null; then
            local gpu_info
            gpu_info=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -1)
            echo -e "${GREEN}✓ GPU detected: $gpu_info${NC}"
        else
            echo -e "${YELLOW}⚠ NVIDIA GPU tools found but GPU not accessible${NC}"
            ((warnings++))
        fi
    fi

    if [[ $warnings -gt 0 ]]; then
        echo -e "${YELLOW}System check completed with $warnings warning(s)${NC}"
    fi

    return 0
}

# Model validation and management
validate_model() {
    local model_name="$1"

    if [[ -z "$model_name" ]]; then
        echo -e "${RED}✗ Model name cannot be empty${NC}"
        return 1
    fi

    # Sanitize model name
    if [[ ! "$model_name" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        echo -e "${RED}✗ Invalid model name: $model_name${NC}"
        echo -e "${YELLOW}Model names can only contain: letters, numbers, dots, hyphens, colons${NC}"
        return 1
    fi

    # Check if model exists locally
    if ollama list | grep -q "^$model_name"; then
        echo -e "${GREEN}✓ Model '$model_name' found locally${NC}"
        return 0
    fi

    # Check if model exists in registry
    echo -e "${CYAN}🔍 Checking model availability in registry...${NC}"

    # Try to get model info without downloading
    if timeout 30 ollama show "$model_name" &> /dev/null; then
        echo -e "${GREEN}✓ Model '$model_name' found in registry${NC}"
        return 0
    else
        echo -e "${RED}✗ Model '$model_name' not found${NC}"
        echo -e "${YELLOW}Suggestions:${NC}"
        echo -e "  • Check spelling: ollama list"
        echo -e "  • Browse available models: https://ollama.ai/library"
        echo -e "  • Try similar models: llama3.2, mistral, gemma2"
        log_error "ERROR" "Model not found: $model_name"
        return 1
    fi
}

# Safe model download with progress and error handling
safe_model_download() {
    local model_name="$1"
    local max_retries=3
    local retry=0

    while [[ $retry -lt $max_retries ]]; do
        echo -e "${CYAN}📥 Downloading '$model_name' (attempt $((retry + 1))/$max_retries)...${NC}"

        # Start download with timeout
        if timeout "$DOWNLOAD_TIMEOUT" ollama pull "$model_name"; then
            echo -e "${GREEN}✓ Model '$model_name' downloaded successfully${NC}"
            log_error "INFO" "Model downloaded: $model_name"
            return 0
        else
            local exit_code=$?

            case $exit_code in
                124)
                    echo -e "${RED}✗ Download timeout after ${DOWNLOAD_TIMEOUT}s${NC}"
                    log_error "ERROR" "Download timeout: $model_name"
                    ;;
                130)
                    echo -e "${YELLOW}Download interrupted by user${NC}"
                    return 1
                    ;;
                *)
                    echo -e "${RED}✗ Download failed (exit code: $exit_code)${NC}"
                    log_error "ERROR" "Download failed: $model_name (exit code: $exit_code)"
                    ;;
            esac

            ((retry++))

            if [[ $retry -lt $max_retries ]]; then
                echo -e "${YELLOW}Retrying in 5 seconds...${NC}"
                sleep 5
            fi
        fi
    done

    echo -e "${RED}✗ Failed to download '$model_name' after $max_retries attempts${NC}"
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "  • Check network connection"
    echo -e "  • Verify model name: ollama search $model_name"
    echo -e "  • Try smaller model first"
    echo -e "  • Check disk space"

    return 1
}

# Input validation and sanitization
validate_user_input() {
    local input="$1"
    local input_type="$2"

    case "$input_type" in
        "choice")
            if [[ ! "$input" =~ ^[0-9]+$ ]] || [[ $input -lt 0 ]] || [[ $input -gt 55 ]]; then
                echo -e "${RED}✗ Invalid choice: $input${NC}"
                echo -e "${YELLOW}Please enter a number between 0-55${NC}"
                return 1
            fi
            ;;
        "profile")
            if [[ ! "$input" =~ ^[1-9]$ ]]; then
                echo -e "${RED}✗ Invalid profile: $input${NC}"
                echo -e "${YELLOW}Please enter a number between 1-9${NC}"
                return 1
            fi
            ;;
        "model_name")
            if [[ ${#input} -gt 100 ]] || [[ ! "$input" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
                echo -e "${RED}✗ Invalid model name: $input${NC}"
                echo -e "${YELLOW}Model names must be under 100 characters and contain only letters, numbers, dots, hyphens, colons${NC}"
                return 1
            fi
            ;;
        "temperature")
            if ! [[ "$input" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$input > 2.0" | bc -l) )); then
                echo -e "${RED}✗ Invalid temperature: $input${NC}"
                echo -e "${YELLOW}Temperature must be a number between 0.0-2.0${NC}"
                return 1
            fi
            ;;
    esac

    return 0
}

# Runtime error monitoring
monitor_model_execution() {
    local model_name="$1"
    local timeout_duration=300  # 5 minutes

    echo -e "${CYAN}🎯 Starting model '$model_name' with monitoring...${NC}"

    # Start model and get PID
    local start_time=$(date +%s)

    # Monitor for common issues
    {
        sleep $timeout_duration
        echo -e "${YELLOW}⚠ Model running longer than expected (${timeout_duration}s)${NC}"
        echo -e "${YELLOW}Press Ctrl+C to interrupt if needed${NC}"
    } &
    local timeout_pid=$!

    # Cleanup function
    cleanup_monitoring() {
        kill $timeout_pid 2>/dev/null
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_error "INFO" "Model session duration: ${duration}s"
    }

    # Set trap for cleanup
    trap cleanup_monitoring EXIT INT TERM

    return 0
}

# ===============================================
# END ERROR HANDLING SYSTEM
# ===============================================

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
                DEBUG_MODE) DEBUG_MODE="$value" ;;
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

# REPLACED: Old check_ollama_service() function replaced with comprehensive error handling system
# Comprehensive system initialization with error handling
initialize_system() {
    echo -e "${CYAN}🔧 Initializing Universal Ollama Optimizer...${NC}"
    echo

    # Run comprehensive system validation
    if ! validate_system; then
        echo -e "${RED}✗ System validation failed${NC}"
        echo -e "${YELLOW}Please resolve the issues above and try again${NC}"
        exit 1
    fi

    # Validate network connectivity (for model downloads)
    if ! validate_network; then
        echo -e "${YELLOW}⚠ Network issues detected - offline model usage only${NC}"
        echo "Continuing with local models..."
        echo
    fi

    # Validate Ollama installation and service
    if ! validate_ollama_installation; then
        echo -e "${RED}✗ Ollama validation failed${NC}"
        echo -e "${YELLOW}Please install/fix Ollama and try again${NC}"
        exit 1
    fi

    # Check system resources
    if ! validate_system_resources; then
        echo -e "${RED}✗ System resource check failed${NC}"
        echo -e "${YELLOW}Please address resource issues and try again${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ System initialization completed successfully${NC}"
    echo
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
    echo -e "${CYAN} 4)${NC} glm4:latest              ${GREEN}[9GB RAM]${NC}  - Ranks 3rd overall, beats Llama 3 8B"
    echo -e "${CYAN} 5)${NC} gemma3:27b               ${GREEN}[32GB RAM]${NC} - Google's most capable single-GPU model"
    echo -e "${CYAN} 6)${NC} llama3.3:70b-instruct    ${GREEN}[64GB RAM]${NC} - Meta's 2025 flagship, rivals GPT-4"
    echo

    echo -e "${YELLOW}💻 PREMIER CODING MODELS (2025 Latest)${NC}"
    echo -e "${CYAN} 7)${NC} qwen3-coder:30b          ${GREEN}[30GB RAM]${NC} - Alibaba's latest 2025 coding model"
    echo -e "${CYAN} 8)${NC} deepseek-coder:33b       ${GREEN}[32GB RAM]${NC} - #1 coding model, complex tasks"
    echo -e "${CYAN} 9)${NC} magicoder:latest         ${GREEN}[7GB RAM]${NC}  - OSS-Instruct trained coding specialist"
    echo -e "${CYAN}10)${NC} codellama:34b            ${GREEN}[32GB RAM]${NC} - Meta's specialized coding model"
    echo -e "${CYAN}11)${NC} qwen2.5-coder:32b        ${GREEN}[32GB RAM]${NC} - Previous Alibaba code model"
    echo -e "${CYAN}12)${NC} codellama:13b-instruct   ${GREEN}[16GB RAM]${NC} - Balanced coding performance"
    echo -e "${CYAN}13)${NC} codegemma:7b             ${GREEN}[8GB RAM]${NC}  - Google's coding model"
    echo

    echo -e "${YELLOW}⚡ RESOURCE-EFFICIENT CHAMPIONS (2025 Latest)${NC}"
    echo -e "${CYAN}14)${NC} phi4:14b                 ${GREEN}[14GB RAM]${NC} - Microsoft's 2025 state-of-the-art"
    echo -e "${CYAN}15)${NC} phi4-mini                ${GREEN}[4GB RAM]${NC}  - 2025 multilingual & reasoning"
    echo -e "${CYAN}15)${NC} granite3.3:8b            ${GREEN}[8GB RAM]${NC}  - IBM's improved 128K context model"
    echo -e "${CYAN}16)${NC} gemma3:12b               ${GREEN}[12GB RAM]${NC} - Google's 2025 efficient model"
    echo -e "${CYAN}17)${NC} gemma3:4b                ${GREEN}[4GB RAM]${NC}  - Compact Google 2025 model"
    echo -e "${CYAN}18)${NC} gemma3:270m              ${GREEN}[300MB RAM]${NC} - Ultra-compact 270M edge model"
    echo -e "${CYAN}19)${NC} mistral:7b-instruct      ${GREEN}[8GB RAM]${NC}  - Community favorite for beginners"
    echo -e "${CYAN}20)${NC} llama3.2:3b             ${GREEN}[4GB RAM]${NC}  - Compact Llama for lightweight"
    echo -e "${CYAN}21)${NC} gemma3:1b                ${GREEN}[2GB RAM]${NC}  - Ultra-lightweight 2025 model"
    echo -e "${CYAN}22)${NC} granite3.3:2b            ${GREEN}[2GB RAM]${NC}  - IBM's efficient 2B enterprise model"
    echo

    echo -e "${YELLOW}🎨 CREATIVE & MULTIMODAL${NC}"
    echo -e "${CYAN}24)${NC} gemma3n:latest           ${GREEN}[8GB RAM]${NC}  - Multimodal for everyday devices"
    echo -e "${CYAN}25)${NC} llava:latest             ${GREEN}[16GB RAM]${NC} - Leading vision model for images"
    echo -e "${CYAN}26)${NC} qwen-vl                  ${GREEN}[16GB RAM]${NC} - Advanced multimodal processing"
    echo -e "${CYAN}27)${NC} gemma2:27b               ${GREEN}[32GB RAM]${NC} - Excellent creative writing"
    echo -e "${CYAN}28)${NC} llava:34b                ${GREEN}[32GB RAM]${NC} - Large vision language model"
    echo -e "${CYAN}29)${NC} bakllava:latest          ${GREEN}[16GB RAM]${NC} - Alternative vision model"
    echo -e "${CYAN}30)${NC} moondream:latest         ${GREEN}[2GB RAM]${NC}  - Smallest vision model (1.8B)"
    echo

    echo -e "${YELLOW}🧠 SPECIALIZED MODELS${NC}"
    echo -e "${CYAN}31)${NC} llama3.1:405b           ${GREEN}[256GB RAM]${NC} - Massive flagship model"
    echo -e "${CYAN}32)${NC} mixtral:8x7b             ${GREEN}[32GB RAM]${NC} - Mixture of Experts model"
    echo -e "${CYAN}33)${NC} mixtral:8x22b            ${GREEN}[64GB RAM]${NC} - Large MoE model"
    echo -e "${CYAN}34)${NC} command-r:35b            ${GREEN}[32GB RAM]${NC} - Cohere's command model"
    echo -e "${CYAN}35)${NC} wizard-vicuna:13b        ${GREEN}[16GB RAM]${NC} - Enhanced conversation model"
    echo -e "${CYAN}36)${NC} orca-mini:13b            ${GREEN}[16GB RAM]${NC} - Microsoft's Orca variant"
    echo

    echo -e "${YELLOW}🔬 RESEARCH & ANALYSIS${NC}"
    echo -e "${CYAN}37)${NC} llama3-gradient:8b       ${GREEN}[8GB RAM]${NC}  - Enhanced reasoning"
    echo -e "${CYAN}38)${NC} vicuna:13b               ${GREEN}[16GB RAM]${NC} - Research assistant model"
    echo -e "${CYAN}39)${NC} openchat:latest          ${GREEN}[8GB RAM]${NC}  - Open conversation model"
    echo -e "${CYAN}40)${NC} starling-lm:7b           ${GREEN}[8GB RAM]${NC}  - Berkeley research model"
    echo -e "${CYAN}41)${NC} zephyr:7b                ${GREEN}[8GB RAM]${NC}  - Hugging Face model"
    echo

    echo -e "${YELLOW}🌐 MULTILINGUAL MODELS${NC}"
    echo -e "${CYAN}42)${NC} qwen2.5:14b             ${GREEN}[16GB RAM]${NC} - Strong multilingual support"
    echo -e "${CYAN}43)${NC} yi:34b                   ${GREEN}[32GB RAM]${NC} - Chinese-English bilingual"
    echo -e "${CYAN}44)${NC} aya:35b                  ${GREEN}[32GB RAM]${NC} - Multilingual instruction model"
    echo -e "${CYAN}45)${NC} chinese-llama2:7b        ${GREEN}[8GB RAM]${NC}  - Chinese language model"
    echo -e "${CYAN}46)${NC} baichuan2:7b             ${GREEN}[8GB RAM]${NC}  - Chinese conversation model"
    echo

    echo -e "${YELLOW}⚡ SPEED & EFFICIENCY${NC}"
    echo -e "${CYAN}46)${NC} neural-chat:7b           ${GREEN}[8GB RAM]${NC}  - Fast conversation model"
    echo -e "${CYAN}47)${NC} dolphin-mistral:7b       ${GREEN}[8GB RAM]${NC}  - Uncensored variant"
    echo -e "${CYAN}48)${NC} solar:10.7b              ${GREEN}[12GB RAM]${NC} - Solar Pro model"
    echo -e "${CYAN}49)${NC} nous-hermes2:latest      ${GREEN}[8GB RAM]${NC}  - Nous Research model"
    echo -e "${CYAN}50)${NC} alpaca:7b                ${GREEN}[8GB RAM]${NC}  - Stanford's Alpaca"
    echo

    echo -e "${YELLOW}🎯 FINE-TUNED VARIANTS${NC}"
    echo -e "${CYAN}51)${NC} llama3-chatqa:8b         ${GREEN}[8GB RAM]${NC}  - Q&A specialized"
    echo -e "${CYAN}52)${NC} llama3-instruct:8b       ${GREEN}[8GB RAM]${NC}  - Instruction following"
    echo -e "${CYAN}53)${NC} mistral-openorca:7b      ${GREEN}[8GB RAM]${NC}  - OpenOrca fine-tune"
    echo -e "${CYAN}54)${NC} wizard-math:7b           ${GREEN}[8GB RAM]${NC}  - Mathematics specialist"
    echo -e "${CYAN}55)${NC} medllama2:7b             ${GREEN}[8GB RAM]${NC}  - Medical domain model"
    echo

    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}💡 TIP: For beginners, try options 2, 12, or 15 (8GB RAM models)${NC}"
    echo -e "${PURPLE}🚀 For coding, try options 6, 7, or 9 (coding specialists)${NC}"
    echo -e "${PURPLE}🖼️ For vision tasks, try options 19, 20, or 24 (multimodal)${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo

    # Array of model names and descriptions corresponding to menu numbers (2025 LATEST)
    MODELS=(
        "gpt-oss:20b" "gpt-oss:120b" "deepseek-r1" "glm4:latest" "gemma3:27b" "llama3.3:70b-instruct"
        "qwen3-coder:30b" "deepseek-coder:33b" "magicoder:latest" "codellama:34b" "qwen2.5-coder:32b" "codellama:13b-instruct"
        "codegemma:7b" "phi4:14b" "phi4-mini" "granite3.3:8b" "gemma3:12b" "gemma3:4b"
        "gemma3:270m" "mistral:7b-instruct" "llama3.2:3b" "gemma3:1b" "granite3.3:2b" "gemma3n:latest"
        "llava:latest" "qwen-vl" "gemma2:27b" "llava:34b" "bakllava:latest" "moondream:latest"
        "llama3.1:405b" "mixtral:8x7b" "mixtral:8x22b" "command-r:35b" "wizard-vicuna:13b"
        "orca-mini:13b" "llama3-gradient:8b" "vicuna:13b" "openchat:latest" "starling-lm:7b"
        "zephyr:7b" "qwen2.5:14b" "yi:34b" "aya:35b" "chinese-llama2:7b"
        "baichuan2:7b" "neural-chat:7b" "dolphin-mistral:7b" "solar:10.7b" "nous-hermes2:latest"
        "alpaca:7b" "llama3-chatqa:8b" "llama3-instruct:8b" "mistral-openorca:7b" "wizard-math:7b" "medllama2:7b"
    )

    # Model descriptions array (corresponding to MODELS array) - 2025 LATEST
    MODEL_DESCRIPTIONS=(
        "OpenAI's new open-weight model" "OpenAI's flagship open model" "671B reasoning with thinking mode" "Ranks 3rd overall, beats Llama 3 8B" "Google's most capable single-GPU model" "Meta's 2025 flagship, rivals GPT-4"
        "Alibaba's latest 2025 coding model" "#1 coding model, complex tasks" "OSS-Instruct trained coding specialist" "Meta's specialized coding model" "Previous Alibaba code model" "Balanced coding performance"
        "Google's coding model" "Microsoft's 2025 state-of-the-art" "2025 multilingual & reasoning" "IBM's improved 128K context model" "Google's 2025 efficient model" "Compact Google 2025 model"
        "Ultra-compact 270M edge model" "Community favorite for beginners" "Compact Llama lightweight" "Ultra-lightweight 2025 model" "IBM's efficient 2B enterprise model" "Multimodal for everyday devices"
        "Leading vision model for images" "Advanced multimodal processing" "Excellent creative writing" "Large vision language model" "Alternative vision model" "Smallest vision model (1.8B)"
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

        # Validate user input
        if ! validate_user_input "$choice" "choice"; then
            continue
        fi

        case $choice in
            0)
                echo -e "${YELLOW}Goodbye!${NC}"
                exit 0
                ;;
            51)
                echo
                read -p "Enter custom model name (e.g., llama3.2:latest): " custom_model

                # Validate and sanitize model name
                if validate_user_input "$custom_model" "model_name"; then
                    if validate_model "$custom_model"; then
                        MODEL_NAME="$custom_model"
                        return 0
                    else
                        echo -e "${YELLOW}Model validation failed. Press Enter to continue...${NC}"
                        read
                        continue
                    fi
                else
                    continue
                fi
                ;;
            52)
                echo
                list_available_models
                echo
                read -p "Enter model name from above list: " local_model

                # Validate and sanitize model name
                if validate_user_input "$local_model" "model_name"; then
                    if validate_model "$local_model"; then
                        MODEL_NAME="$local_model"
                        return 0
                    else
                        echo -e "${YELLOW}Model validation failed. Press Enter to continue...${NC}"
                        read
                        continue
                    fi
                else
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
            [1-9]|[1-4][0-9]|5[0-3])
                if [[ $choice -ge 1 && $choice -le 50 ]]; then
                    MODEL_NAME="${MODELS[$((choice-1))]}"
                    echo -e "${GREEN}Selected: ${CYAN}$MODEL_NAME${NC}"

                    # Validate selected model
                    if validate_model "$MODEL_NAME"; then
                        return 0
                    else
                        echo -e "${YELLOW}Model validation failed. Press Enter to continue...${NC}"
                        read
                        continue
                    fi
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

    # Initialize system with comprehensive validation
    initialize_system

    # Get model selection from user using comprehensive menu
    get_model_selection

    # Model validation is now handled in get_model_selection
    if [[ -z "$MODEL_NAME" ]]; then
        echo -e "${RED}No model name provided. Exiting.${NC}"
        log_error "ERROR" "No model name provided"
        exit 1
    fi

    # Check if model needs to be downloaded
    if ! ollama list | grep -q "^$MODEL_NAME"; then
        echo -e "${CYAN}Model '$MODEL_NAME' not found locally. Downloading...${NC}"
        if ! safe_model_download "$MODEL_NAME"; then
            echo -e "${RED}Failed to download model. Exiting.${NC}"
            log_error "ERROR" "Failed to download model: $MODEL_NAME"
            exit 1
        fi
    fi

    # Start monitoring for this session
    monitor_model_execution "$MODEL_NAME"

    show_header
    get_model_info "$MODEL_NAME"
    check_system_resources
    show_profile_selection

    # Get profile selection with validation
    while true; do
        read -p "Select profile [1-9] (default: 1): " choice
        choice=${choice:-1}

        # Validate profile selection
        if validate_user_input "$choice" "profile"; then
            break
        fi
        echo -e "${YELLOW}Please try again.${NC}"
    done

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

    echo -e "${GREEN}Starting $MODEL_NAME with $SELECTED_PROFILE profile...${NC}"
    echo -e "${CYAN}Press Ctrl+C to exit${NC}"
    echo

    # Log session start
    log_error "INFO" "Starting model session: $MODEL_NAME with $SELECTED_PROFILE profile"

    # Launch the model with error handling
    if ! ollama run "$MODEL_NAME"; then
        local exit_code=$?
        echo -e "${RED}✗ Model execution failed (exit code: $exit_code)${NC}"

        # Provide troubleshooting suggestions
        echo -e "${YELLOW}Troubleshooting suggestions:${NC}"
        echo -e "  • Check if model is corrupted: ollama rm $MODEL_NAME && ollama pull $MODEL_NAME"
        echo -e "  • Verify system resources: free -h && df -h"
        echo -e "  • Check Ollama service: pgrep ollama"
        echo -e "  • View error log: tail -20 $ERROR_LOG"

        log_error "ERROR" "Model execution failed: $MODEL_NAME (exit code: $exit_code)"
        exit $exit_code
    fi

    # Log successful completion
    log_error "INFO" "Model session completed successfully: $MODEL_NAME"
}

# Run main function
main "$@"
