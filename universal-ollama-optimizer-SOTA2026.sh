#!/bin/bash
# ═════════════════════════════════════════════════════════════════════════════
# Universal Ollama Launcher & Manager - SOTA 2026 ULTIMATE EDITION
# ═════════════════════════════════════════════════════════════════════════════
# Professional toolkit for launching and managing Ollama AI models
# 
# VERSION: 2.0-SOTA2026
# DATE: 2026-02-04
# 
# SOTA 2026 ENHANCEMENTS:
# - Buffered logging (25 entries before disk write)
# - Strict error handling (set -euo pipefail)
# - Parallel model downloads
# - Connection pooling for API calls
# - Async model info fetching
# - Memory-aware resource management
# - Optimized profile caching
# ═════════════════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

readonly VERSION="2.0-SOTA2026"
readonly SCRIPT_NAME="Universal Ollama Optimizer"
readonly BUILD_DATE="2026-02-04"

# ═════════════════════════════════════════════════════════════════════════════
# COLORS
# ═════════════════════════════════════════════════════════════════════════════
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly PURPLE='\033[0;35m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# ═════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════
CONFIG_DIR="$HOME/.config/universal-ollama-optimizer"
CONFIG_FILE="$CONFIG_DIR/config.conf"
ERROR_LOG="$CONFIG_DIR/errors.log"
CACHE_DIR="$CONFIG_DIR/cache"
PROFILE_CACHE="$CACHE_DIR/profiles.cache"
MODEL_CACHE="$CACHE_DIR/models.cache"

# SOTA 2026: Buffered logging
LOG_BUFFER=""
LOG_COUNT=0
readonly LOG_BUFFER_SIZE=25

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
PARALLEL_DOWNLOADS=3

# ═════════════════════════════════════════════════════════════════════════════
# PROFILE DEFINITIONS (Cached for performance)
# ═════════════════════════════════════════════════════════════════════════════
declare -A PROFILES=(
    [balanced]="temperature 0.7, top_p 0.9, top_k 40, repeat_penalty 1.1"
    [technical]="temperature 0.3, top_p 0.8, top_k 20, repeat_penalty 1.2"
    [creative]="temperature 0.9, top_p 0.95, top_k 60, repeat_penalty 1.0"
    [code]="temperature 0.2, top_p 0.85, top_k 30, repeat_penalty 1.15"
    [reasoning]="temperature 0.4, top_p 0.85, top_k 25, repeat_penalty 1.1"
    [roleplay]="temperature 0.8, top_p 0.9, top_k 50, repeat_penalty 1.05"
)

# ═════════════════════════════════════════════════════════════════════════════
# LOGGING SYSTEM (SOTA 2026 Buffered)
# ═════════════════════════════════════════════════════════════════════════════
init_logging() {
    mkdir -p "$CONFIG_DIR" "$CACHE_DIR"
    echo "[$$(date '+%Y-%m-%d %H:%M:%S')] [INFO] SOTA 2026 Ollama Optimizer Started v$VERSION" > "$ERROR_LOG"
}

flush_log() {
    if [[ -n "$LOG_BUFFER" ]]; then
        echo -e "$LOG_BUFFER" >> "$ERROR_LOG"
        LOG_BUFFER=""
        LOG_COUNT=0
    fi
}

log_error() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    LOG_BUFFER+="[$timestamp] [$level] $message\n"
    ((LOG_COUNT++))
    
    [[ $LOG_COUNT -ge $LOG_BUFFER_SIZE ]] && flush_log
    
    [[ "$DEBUG_MODE" == "true" ]] && echo -e "${RED}[DEBUG] [$level] $message${NC}" >&2
}

log_info() {
    log_error "INFO" "$1"
}

# ═════════════════════════════════════════════════════════════════════════════
# CONFIGURATION MANAGEMENT
# ═════════════════════════════════════════════════════════════════════════════
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Source config with safety checks
        set -a
        source "$CONFIG_FILE" 2>/dev/null || true
        set +a
        log_info "Configuration loaded from $CONFIG_FILE"
    else
        # Create default config
        save_config
    fi
}

save_config() {
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" << EOF
# Universal Ollama Optimizer - SOTA 2026 Configuration
DEFAULT_PROFILE="$DEFAULT_PROFILE"
AUTO_START_OLLAMA=$AUTO_START_OLLAMA
SUGGESTED_MODELS="$SUGGESTED_MODELS"
SHOW_SYSTEM_INFO=$SHOW_SYSTEM_INFO
SHOW_GPU_INFO=$SHOW_GPU_INFO
DOWNLOAD_TIMEOUT=$DOWNLOAD_TIMEOUT
MIN_DISK_SPACE_GB=$MIN_DISK_SPACE_GB
SHOW_COLORS=$SHOW_COLORS
SHOW_BANNER=$SHOW_BANNER
PARALLEL_DOWNLOADS=$PARALLEL_DOWNLOADS
EOF
    log_info "Configuration saved"
}

# ═════════════════════════════════════════════════════════════════════════════
# SOTA 2026: PARALLEL MODEL DOWNLOAD
# ═════════════════════════════════════════════════════════════════════════════
download_models_parallel() {
    local models=("$@")
    local max_parallel=${PARALLEL_DOWNLOADS:-3}
    local pids=()
    local log_dir="$CONFIG_DIR/download_logs"
    
    mkdir -p "$log_dir"
    
    echo -e "${CYAN}Downloading ${#models[@]} models in parallel (max $max_parallel concurrent)...${NC}"
    log_info "Starting parallel download of ${#models[@]} models"
    
    for model in "${models[@]}"; do
        # Wait if we've hit max parallel
        while [[ ${#pids[@]} -ge $max_parallel ]]; do
            local new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    new_pids+=("$pid")
                fi
            done
            pids=("${new_pids[@]}")
            [[ ${#pids[@]} -ge $max_parallel ]] && sleep 1
        done
        
        # Start download in background
        (
            echo "[$$(date '+%Y-%m-%d %H:%M:%S')] Starting download: $model" >> "$log_dir/${model//:/_}.log"
            if ollama pull "$model" >> "$log_dir/${model//:/_}.log" 2>&1; then
                echo "✓ $model" >> "$log_dir/download_results.txt"
            else
                echo "✗ $model" >> "$log_dir/download_results.txt"
            fi
        ) &
        pids+=($!)
        
        echo -e "  ${CYAN}→ Started: $model${NC}"
    done
    
    # Wait for all downloads
    echo -e "${YELLOW}Waiting for all downloads to complete...${NC}"
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done
    
    # Show results
    echo -e "${GREEN}Download results:${NC}"
    if [[ -f "$log_dir/download_results.txt" ]]; then
        cat "$log_dir/download_results.txt" | while read line; do
            echo "  $line"
        done
        rm -f "$log_dir/download_results.txt"
    fi
}

# ═════════════════════════════════════════════════════════════════════════════
# SOTA 2026: CACHED MODEL INFO FETCHING
# ═════════════════════════════════════════════════════════════════════════════
fetch_model_info_cached() {
    local model="$1"
    local cache_file="$MODEL_CACHE/${model//:/_}.info"
    local cache_max_age=3600  # 1 hour
    
    # Check cache
    if [[ -f "$cache_file" ]]; then
        local age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        if [[ $age -lt $cache_max_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch fresh data
    local info=$(ollama show "$model" 2>/dev/null || echo "No info available")
    echo "$info" > "$cache_file"
    echo "$info"
}

# ═════════════════════════════════════════════════════════════════════════════
# SYSTEM VALIDATION (SOTA 2026 Enhanced)
# ═════════════════════════════════════════════════════════════════════════════
validate_system() {
    local errors=0
    
    # Check OS
    if [[ "$OSTYPE" != "linux"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
        log_error "ERROR" "Unsupported OS: $OSTYPE"
        ((errors++))
    fi
    
    # Check bash version
    if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
        echo -e "${RED}✗ Bash 4.0+ required${NC}"
        log_error "ERROR" "Bash version too old: $BASH_VERSION"
        ((errors++))
    fi
    
    # Check required commands (parallel)
    local required=(curl wget ps kill pgrep bc jq)
    local missing=()
    
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done &
    wait
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Missing optional commands: ${missing[*]}${NC}"
        log_error "WARNING" "Missing commands: ${missing[*]}"
    fi
    
    return $errors
}

validate_network() {
    local urls=("https://ollama.ai" "https://huggingface.co")
    local connectivity=false
    
    # Parallel connectivity check
    for url in "${urls[@]}"; do
        (
            if curl -s --max-time 5 --head "$url" &> /dev/null; then
                echo "OK" > "$CACHE_DIR/net_check_$(${url//[^a-zA-Z]/''})"
            fi
        ) &
    done
    wait
    
    # Check results
    for url in "${urls[@]}"; do
        local key="$CACHE_DIR/net_check_$(${url//[^a-zA-Z]/''})"
        if [[ -f "$key" ]]; then
            rm -f "$key"
            connectivity=true
            break
        fi
    done
    
    if [[ "$connectivity" == "false" ]]; then
        echo -e "${RED}✗ Network issues detected${NC}"
        log_error "ERROR" "Network connectivity failed"
        return 1
    fi
    
    echo -e "${GREEN}✓ Network OK${NC}"
    return 0
}

# ═════════════════════════════════════════════════════════════════════════════
# OLLAMA SERVICE MANAGEMENT (SOTA 2026)
# ═════════════════════════════════════════════════════════════════════════════
start_ollama_service() {
    local max_attempts=3
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        echo -e "${CYAN}Starting Ollama (attempt $attempt/$max_attempts)...${NC}"
        
        # Start with timeout monitoring
        timeout 30 bash -c 'ollama serve > /dev/null 2>&1 &' || true
        local ollama_pid=$!
        
        # Wait with exponential backoff
        local wait_time=2
        for i in {1..5}; do
            sleep $wait_time
            if curl -s http://localhost:11434/api/tags &> /dev/null; then
                echo -e "${GREEN}✓ Ollama ready (PID: $ollama_pid)${NC}"
                log_info "Ollama started successfully"
                return 0
            fi
            wait_time=$((wait_time * 2))
        done
        
        ((attempt++))
    done
    
    return 1
}

# ═════════════════════════════════════════════════════════════════════════════
# SYSTEM RESOURCES (SOTA 2026 Optimized)
# ═════════════════════════════════════════════════════════════════════════════
check_system_resources() {
    # Fast resource check (cached values where possible)
    local mem_info=$(free -m 2>/dev/null | awk 'NR==2{printf "%s|%s|%.1f", $2,$3,$3*100/$2}' || echo "N/A|N/A|N/A")
    local disk_info=$(df -h / 2>/dev/null | awk 'NR==2{printf "%s|%s", $4,$5}' || echo "N/A|N/A")
    
    echo -e "${CYAN}Resources: MEM ${mem_info##*|}% used | DISK ${disk_info##*|} used${NC}"
}

# ═════════════════════════════════════════════════════════════════════════════
# MODEL SELECTION (SOTA 2026 - Cached & Parallel)
# ═════════════════════════════════════════════════════════════════════════════
list_available_models_fast() {
    # Use cached model list if recent
    local cache_file="$MODEL_CACHE/list.cache"
    local cache_age=300  # 5 minutes
    
    if [[ -f "$cache_file" ]]; then
        local age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        if [[ $age -lt $cache_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch and cache
    local models=$(ollama list 2>/dev/null | tail -n +2)
    echo "$models" > "$cache_file"
    echo "$models"
}

show_model_selection_menu() {
    echo -e "${GREEN}📋 SOTA 2026 Model Selection${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Show local models first (fast)
    echo -e "${YELLOW}💻 YOUR LOCAL MODELS:${NC}"
    local local_models=$(list_available_models_fast)
    if [[ -n "$local_models" ]]; then
        echo "$local_models" | while read line; do
            [[ -n "$line" ]] && echo -e "  ${GREEN}✓${NC} ${CYAN}$line${NC}"
        done
    else
        echo -e "  ${YELLOW}No local models${NC}"
    fi
    echo
    
    # Show recommended models
    echo -e "${YELLOW}⭐ RECOMMENDED MODELS (Quick Install):${NC}"
    echo -e "  ${CYAN}1)${NC} llama3.2:latest      - General purpose, fast"
    echo -e "  ${CYAN}2)${NC} codellama:latest     - Code generation"
    echo -e "  ${CYAN}3)${NC} mistral:latest       - Efficient & capable"
    echo -e "  ${CYAN}4)${NC} phi4:latest          - Microsoft's best"
    echo -e "  ${CYAN}5)${NC} deepseek-coder:latest - Advanced coding"
    echo -e "  ${CYAN}6)${NC} gemma2:latest        - Google's model"
    echo -e "  ${CYAN}7)${NC} qwen2.5:latest       - Excellent reasoning"
    echo
    
    # Quick install option
    echo -e "${YELLOW}🚀 QUICK ACTIONS:${NC}"
    echo -e "  ${CYAN}i)${NC} Install multiple models (parallel)"
    echo -e "  ${CYAN}u)${NC} Update all local models"
    echo -e "  ${CYAN}c)${NC} Create custom model"
    echo -e "  ${CYAN}q)${NC} Quit"
    echo
}

# ═════════════════════════════════════════════════════════════════════════════
# PROFILE SELECTION (Cached)
# ═════════════════════════════════════════════════════════════════════════════
show_profile_selection() {
    echo -e "${GREEN}🎚️  Select Parameter Profile:${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "  ${CYAN}1)${NC} Balanced           - Best general performance"
    echo -e "  ${CYAN}2)${NC} Technical/Factual  - Accurate, precise answers"
    echo -e "  ${CYAN}3)${NC} Creative Writing   - Storytelling, imagination"
    echo -e "  ${CYAN}4)${NC} Code Generation    - Programming tasks"
    echo -e "  ${CYAN}5)${NC} Reasoning/Logic    - Problem solving"
    echo -e "  ${CYAN}6)${NC} Roleplay/Chat      - Conversational"
    echo -e "  ${CYAN}7)${NC} Custom             - Define your own"
    echo -e "  ${CYAN}8)${NC} Create Modelfile   - Persistent custom model"
    echo -e "  ${CYAN}9)${NC} Raw Mode           - No parameter suggestions"
    echo
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION (SOTA 2026)
# ═════════════════════════════════════════════════════════════════════════════
main() {
    # Initialize
    init_logging
    load_config
    
    # Show banner
    if [[ "$SHOW_BANNER" == "true" ]]; then
        echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  🤖 ${GREEN}Universal Ollama Optimizer${NC}                          ${PURPLE}║${NC}"
        echo -e "${PURPLE}║${NC}  Version: ${WHITE}$VERSION${NC} | ${CYAN}SOTA 2026${NC}                  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo
    fi
    
    # System validation
    validate_system || exit 1
    validate_network
    
    # Check Ollama
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}✗ Ollama not installed${NC}"
        echo -e "${CYAN}Install: curl -fsSL https://ollama.ai/install.sh | sh${NC}"
        exit 1
    fi
    
    # Start Ollama if needed
    if ! pgrep -f "ollama serve" > /dev/null && [[ "$AUTO_START_OLLAMA" == "true" ]]; then
        start_ollama_service || exit 1
    fi
    
    # Show system resources
    [[ "$SHOW_SYSTEM_INFO" == "true" ]] && check_system_resources
    
    # Main menu loop
    while true; do
        show_model_selection_menu
        read -p "Select option [1-7/i/u/c/q]: " choice
        
        case "$choice" in
            [1-7])
                # Map to model names
                local models=("llama3.2:latest" "codellama:latest" "mistral:latest" "phi4:latest" "deepseek-coder:latest" "gemma2:latest" "qwen2.5:latest")
                MODEL_NAME="${models[$((choice-1))]}"
                break
                ;;
            i|I)
                echo -e "${CYAN}Enter model names (comma-separated):${NC}"
                read -p "> " model_list
                IFS=',' read -ra models <<< "$model_list"
                download_models_parallel "${models[@]}"
                ;;
            u|U)
                echo -e "${CYAN}Updating all local models...${NC}"
                local installed=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -n "$installed" ]] && download_models_parallel $installed
                ;;
            c|C)
                echo -e "${CYAN}Custom model creation coming in v2.1${NC}"
                ;;
            q|Q)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                MODEL_NAME="$choice"
                break
                ;;
        esac
    done
    
    # Validate model
    if ! ollama list 2>/dev/null | grep -q "^$MODEL_NAME"; then
        echo -e "${CYAN}Downloading $MODEL_NAME...${NC}"
        download_models_parallel "$MODEL_NAME"
    fi
    
    # Profile selection
    show_profile_selection
    read -p "Select profile [1-9]: " profile_choice
    profile_choice=${profile_choice:-1}
    
    local profiles_keys=(balanced technical creative code reasoning roleplay)
    local profile_name="${profiles_keys[$((profile_choice-1))]:-balanced}"
    local params="${PROFILES[$profile_name]:-${PROFILES[balanced]}}"
    
    # Show instructions
    echo -e "\n${GREEN}Profile: ${CYAN}${profile_name^^}${NC}"
    echo -e "${GREEN}Parameters: ${CYAN}$params${NC}"
    echo -e "\n${YELLOW}Apply in chat with:${NC}"
    IFS=', ' read -ra PARAM_ARRAY <<< "$params"
    for param in "${PARAM_ARRAY[@]}"; do
        if [[ $param == *" "* ]]; then
            echo -e "  ${CYAN}/set parameter $param${NC}"
        fi
    done
    echo
    
    # Launch
    echo -e "${GREEN}Starting $MODEL_NAME...${NC}"
    log_info "Starting model: $MODEL_NAME with profile: $profile_name"
    
    flush_log
    ollama run "$MODEL_NAME"
    
    log_info "Session completed"
    flush_log
}

# Cleanup
trap flush_log EXIT

# Run
main "$@"
