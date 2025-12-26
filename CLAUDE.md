# CLAUDE.md - Universal Ollama Optimizer

## Project Overview

**Universal Ollama Optimizer** is a professional bash-based toolkit for launching and optimizing Ollama AI models. It provides an intuitive terminal interface with intelligent optimization profiles, comprehensive system monitoring, and automated configuration management.

**Developer**: JTGSYSTEMS.COM | JointTechnologyGroup.com
**Repository**: https://github.com/jtgsystems/universal-ollama-optimizer
**License**: MIT
**Platform**: Linux, macOS
**Language**: Bash 5.0+

---

## Architecture Overview

### Core Components

1. **Main Script** (`universal-ollama-optimizer.sh`)
   - Terminal-based interactive interface
   - Model selection and validation system
   - Optimization profile management
   - System resource monitoring
   - Error handling and logging framework

2. **Installation Script** (`scripts/install.sh`)
   - Automated installation process
   - Ollama dependency checking
   - Script deployment and permissions setup

3. **Configuration System**
   - File-based configuration: `~/.config/universal-ollama-optimizer/config.conf`
   - Runtime parameter overrides
   - Persistent user preferences

4. **Documentation**
   - `README.md` - Comprehensive user guide
   - `CONTRIBUTING.md` - Contributor guidelines
   - `CHANGELOG.md` - Version history
   - `docs/` - Additional documentation

---

## Project Structure

```
universal-ollama-optimizer/
├── universal-ollama-optimizer.sh    # Main executable (1192 lines)
├── scripts/
│   └── install.sh                   # Installation script
├── docs/
│   ├── INSTALLATION.md              # Installation guide
│   └── TROUBLESHOOTING.md          # Troubleshooting guide
├── examples/
│   └── basic-usage.sh              # Usage examples
├── .github/
│   ├── workflows/                  # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/             # Issue templates
│   └── PULL_REQUEST_TEMPLATE.md    # PR template
├── README.md                        # Project documentation
├── CONTRIBUTING.md                  # Contribution guidelines
├── CHANGELOG.md                     # Version history
├── LICENSE                          # MIT License
└── banner.png                       # Project banner
```

---

## Key Features

### 1. Universal Model Support
- Works with 55+ categorized models (as of September 2025)
- Auto-download and validation
- Model compatibility checking
- Disk space validation before download

### 2. Optimization Profiles
Six pre-configured profiles for different use cases:

| Profile | Temperature | Top-P | Top-K | Use Case |
|---------|-------------|-------|-------|----------|
| **Balanced** | 0.5 | 0.85 | 30 | General purpose, Q&A |
| **Technical** | 0.2 | 0.8 | 20 | Documentation, factual responses |
| **Creative** | 1.0 | 0.95 | 50 | Creative writing, brainstorming |
| **Code** | 0.15 | 0.7 | 15 | Programming, debugging |
| **Reasoning** | 0.3 | 0.75 | 25 | Logic, problem-solving |
| **Roleplay** | 0.8 | 0.9 | 40 | Character chat, conversations |

### 3. System Resource Monitoring
- GPU memory detection (NVIDIA)
- System RAM monitoring
- Available disk space checking
- Resource warnings and recommendations

### 4. Comprehensive Error Handling
- Network connectivity validation
- Ollama installation verification
- Service health checks
- Model validation and sanitization
- Download timeout management
- Detailed error logging to `~/.config/universal-ollama-optimizer/errors.log`

### 5. Advanced Features
- Custom parameter configuration
- Modelfile creation for permanent optimizations
- Model update functionality
- Debug mode for troubleshooting
- Runtime command integration

---

## Technical Implementation

### Shell Script Architecture

#### Error Handling System (Lines 35-433)
```bash
# Comprehensive validation functions:
- validate_system()              # OS and bash version checks
- validate_network()             # Network connectivity tests
- validate_ollama_installation() # Ollama verification
- validate_system_resources()    # RAM, disk, GPU checks
- validate_model()               # Model name validation
- safe_model_download()          # Retry logic for downloads
- validate_user_input()          # Input sanitization
- monitor_model_execution()      # Runtime monitoring
```

#### Configuration Management (Lines 436-463)
```bash
# Config file: ~/.config/universal-ollama-optimizer/config.conf
- DEFAULT_PROFILE          # Default optimization profile
- AUTO_START_OLLAMA        # Auto-start Ollama service
- SUGGESTED_MODELS         # Recommended models list
- SHOW_SYSTEM_INFO         # System info display toggle
- SHOW_GPU_INFO            # GPU info display toggle
- DOWNLOAD_TIMEOUT         # Model download timeout (seconds)
- MIN_DISK_SPACE_GB        # Minimum disk space requirement
- SHOW_COLORS              # Color output toggle
- SHOW_BANNER              # Banner display toggle
- DEBUG_MODE               # Debug logging toggle
```

#### Model Selection Menu (Lines 553-675)
- 55+ categorized models organized by:
  - Top-tier models (2025 latest)
  - Premier coding models
  - Resource-efficient champions
  - Creative & multimodal models
  - Specialized models
  - Research & analysis models
  - Multilingual models
  - Speed & efficiency models
  - Fine-tuned variants

#### Profile Management (Lines 466-473)
```bash
# Associative array for optimization profiles
PROFILES=(
    ["balanced"]   = "temperature 0.5, top_p 0.85, top_k 30, repeat_penalty 1.08"
    ["technical"]  = "temperature 0.2, top_p 0.8, top_k 20, repeat_penalty 1.05"
    ["creative"]   = "temperature 1.0, top_p 0.95, top_k 50, repeat_penalty 1.15"
    ["code"]       = "temperature 0.15, top_p 0.7, top_k 15, repeat_penalty 1.02"
    ["reasoning"]  = "temperature 0.3, top_p 0.75, top_k 25, repeat_penalty 1.03"
    ["roleplay"]   = "temperature 0.8, top_p 0.9, top_k 40, repeat_penalty 1.12"
)
```

---

## Usage Workflow

### 1. System Initialization
```bash
initialize_system()
├── validate_system()              # OS, bash version, required commands
├── validate_network()             # Internet connectivity
├── validate_ollama_installation() # Ollama installed and running
└── validate_system_resources()    # RAM, disk, GPU availability
```

### 2. Model Selection
```bash
get_model_selection()
├── show_model_selection_menu()    # Display 55+ models
├── validate_user_input()          # Sanitize choice
├── validate_model()               # Check model exists
└── safe_model_download()          # Download if needed
```

### 3. Profile Selection
```bash
show_profile_selection()
├── Display 9 profile options
├── validate_user_input()          # Validate profile choice
├── handle_custom_parameters()     # If custom selected
└── create_custom_modelfile()      # If modelfile creation selected
```

### 4. Model Execution
```bash
main()
├── load_config()                  # Load user preferences
├── show_header()                  # Display banner
├── initialize_system()            # System validation
├── get_model_selection()          # Choose model
├── show_profile_selection()       # Choose optimization
├── monitor_model_execution()      # Start monitoring
└── ollama run $MODEL_NAME         # Launch model
```

---

## Model Categories (September 2025)

### Top-Tier Models
1. **gpt-oss:20b** - OpenAI's new open-weight model
2. **gpt-oss:120b** - OpenAI's flagship open model
3. **deepseek-r1** - 671B reasoning with thinking mode
4. **glm4:latest** - Ranks 3rd overall, beats Llama 3 8B
5. **gemma3:27b** - Google's most capable single-GPU model
6. **llama3.3:70b-instruct** - Meta's 2025 flagship, rivals GPT-4

### Premier Coding Models
7. **qwen3-coder:30b** - Alibaba's latest 2025 coding model
8. **deepseek-coder:33b** - #1 coding model, complex tasks
9. **magicoder:latest** - OSS-Instruct trained specialist
10. **codellama:34b** - Meta's specialized coding model
11. **qwen2.5-coder:32b** - Previous Alibaba code model
12. **codellama:13b-instruct** - Balanced coding performance
13. **codegemma:7b** - Google's coding model

### Resource-Efficient Champions
14. **phi4:14b** - Microsoft's 2025 state-of-the-art
15. **phi4-mini** - 2025 multilingual & reasoning
16. **granite3.3:8b** - IBM's improved 128K context model
17. **gemma3:12b** - Google's 2025 efficient model
18. **gemma3:4b** - Compact Google 2025 model
19. **gemma3:270m** - Ultra-compact 270M edge model
20. **mistral:7b-instruct** - Community favorite for beginners
21. **llama3.2:3b** - Compact Llama for lightweight
22. **gemma3:1b** - Ultra-lightweight 2025 model
23. **granite3.3:2b** - IBM's efficient 2B enterprise model

### Creative & Multimodal
24. **gemma3n:latest** - Multimodal for everyday devices
25. **llava:latest** - Leading vision model for images
26. **qwen-vl** - Advanced multimodal processing
27. **gemma2:27b** - Excellent creative writing
28. **llava:34b** - Large vision language model
29. **bakllava:latest** - Alternative vision model
30. **moondream:latest** - Smallest vision model (1.8B)

(Plus 25 more specialized, research, multilingual, and fine-tuned models)

---

## Configuration Guide

### Default Configuration
Location: `~/.config/universal-ollama-optimizer/config.conf`

```ini
# Optimization profile
DEFAULT_PROFILE="balanced"

# Service management
AUTO_START_OLLAMA=true

# Model suggestions
SUGGESTED_MODELS="llama3.2:latest,mistral:7b,gemma2:9b,codellama:13b"

# Display settings
SHOW_SYSTEM_INFO=true
SHOW_GPU_INFO=true
SHOW_COLORS=true
SHOW_BANNER=true

# Download settings
DOWNLOAD_TIMEOUT=1800  # 30 minutes
MIN_DISK_SPACE_GB=5

# Debug settings
DEBUG_MODE=false
```

### Error Logging
Location: `~/.config/universal-ollama-optimizer/errors.log`

Log levels:
- **INFO** - Informational messages (session start/end)
- **WARNING** - Non-critical issues (low RAM, network issues)
- **ERROR** - Critical failures (missing dependencies, download failures)

---

## Dependencies

### Required
- **Bash 5.0+** - Shell interpreter
- **Ollama** - AI model runtime
- **curl** - HTTP requests
- **wget** - File downloads
- **ps** - Process management
- **kill** - Process termination
- **pgrep** - Process lookup

### Optional
- **nvidia-smi** - GPU monitoring (NVIDIA only)
- **bc** - Floating-point calculations
- **netstat** - Network statistics

### Installation
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install bash curl wget procps nvidia-utils bc net-tools

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
```

---

## Development Guidelines

### Code Style
- Use descriptive variable names (UPPERCASE for globals)
- Add comments for complex logic
- Error handling for all external commands
- Input validation and sanitization
- Consistent indentation (4 spaces)

### Testing Checklist
- [ ] Test on Ubuntu 20.04+
- [ ] Test on macOS
- [ ] Test with different models
- [ ] Test with limited resources
- [ ] Test error conditions
- [ ] Run shellcheck validation
- [ ] Check bash syntax

### Contribution Workflow
1. Fork repository
2. Create feature branch
3. Make changes and test
4. Run shellcheck validation
5. Update documentation
6. Submit pull request

---

## Troubleshooting

### Common Issues

**Issue**: Ollama service not starting
```bash
# Solution:
sudo systemctl status ollama
sudo systemctl start ollama
# Or manually:
nohup ollama serve > /dev/null 2>&1 &
```

**Issue**: Model download timeout
```bash
# Solution:
# Increase timeout in config.conf
DOWNLOAD_TIMEOUT=3600  # 1 hour

# Or use smaller model variants:
ollama pull llama3.2:3b  # Instead of llama3.2:70b
```

**Issue**: Insufficient disk space
```bash
# Solution:
# Remove unused models
ollama list
ollama rm <unused-model>

# Clean model cache
rm -rf ~/.ollama/models/blobs/*
```

**Issue**: GPU not detected
```bash
# Solution:
# Check NVIDIA drivers
nvidia-smi

# Update drivers if needed
sudo ubuntu-drivers autoinstall
```

---

## Advanced Usage

### Custom Modelfile Creation
```bash
# Select option 8 in profile menu
# Creates custom optimized models permanently
# Example: llama3.2-coding, mistral-creative
```

### Runtime Commands
Once model is running:
```bash
/set parameter temperature 0.7      # Adjust temperature
/set parameter top_p 0.9            # Adjust top_p
/set system "You are a coding assistant"  # Change system prompt
/show parameters                    # View current settings
/show info                          # Model information
/save conversation-name             # Save session
/load conversation-name             # Load session
```

### Debug Mode
```bash
# Enable in config.conf
DEBUG_MODE=true

# View real-time debugging
tail -f ~/.config/universal-ollama-optimizer/errors.log
```

---

## Performance Optimization

### Model Selection Strategy
| Available RAM | Recommended Models | Profile |
|---------------|-------------------|---------|
| 2-4 GB | gemma3:270m, gemma3:1b, granite3.3:2b | Balanced |
| 4-8 GB | mistral:7b, llama3.2:3b, phi4-mini | Balanced/Code |
| 8-16 GB | llama3.1:8b, glm4:latest, granite3.3:8b | Technical/Code |
| 16-32 GB | deepseek-coder:33b, qwen3-coder:30b | Code/Reasoning |
| 32-64 GB | llama3.3:70b, gemma3:27b | All profiles |
| 64+ GB | llama3.1:405b, gpt-oss:120b, deepseek-r1 | All profiles |

### GPU Recommendations
- **No GPU**: Use small models (1B-7B)
- **8GB VRAM**: Medium models (7B-13B)
- **16GB VRAM**: Large models (13B-34B)
- **24GB+ VRAM**: Flagship models (70B+)

---

## API Integration

### Ollama Service
The script uses Ollama's API endpoints:
- `http://localhost:11434/api/tags` - List models
- `http://localhost:11434/api/pull` - Download models
- `http://localhost:11434/api/show` - Model info
- `http://localhost:11434/api/generate` - Generate responses

### Service Management
```bash
# Start service
start_ollama_service()
├── nohup ollama serve &
├── Wait for initialization (3s)
├── Verify API response
└── Retry up to 3 times

# Check service status
pgrep -f "ollama serve"
curl -s http://localhost:11434/api/tags
```

---

## Security Considerations

1. **Input Validation**
   - All user inputs are sanitized
   - Model names restricted to: `[a-zA-Z0-9._:-]+`
   - Numeric inputs validated with range checks
   - Command injection prevention

2. **File Safety**
   - No arbitrary file execution
   - Config files parsed safely
   - Temporary files cleaned up
   - No hardcoded credentials

3. **Network Safety**
   - HTTPS for all downloads
   - Timeout limits on downloads
   - Network validation before downloads
   - Proxy support respected

4. **Resource Protection**
   - Disk space validation before downloads
   - Memory checks before model loading
   - Process monitoring and cleanup
   - Error logging without sensitive data

---

## Future Enhancements

### Planned Features
- [ ] Multi-model comparison mode
- [ ] Benchmark testing suite
- [ ] Performance metrics logging
- [ ] Model recommendation engine
- [ ] GUI version (curses/dialog)
- [ ] Docker container support
- [ ] Kubernetes deployment configs
- [ ] REST API wrapper
- [ ] WebUI integration
- [ ] Model fine-tuning helpers

### Community Requests
- [ ] macOS optimization improvements
- [ ] Windows WSL support
- [ ] AMD GPU support
- [ ] Model quantization options
- [ ] Custom prompt templates
- [ ] Conversation history management
- [ ] Multi-user support
- [ ] Cloud model integration

---

## Version History

### v1.0.0 (2025-01-16)
- Initial production release
- 55+ supported models
- 6 optimization profiles
- Comprehensive error handling
- Full documentation

### v0.9.0 (2025-01-15)
- Beta release
- Core functionality
- Basic system monitoring

### v0.8.0 (2025-01-14)
- Alpha release
- Initial script development

---

## Attribution

**Developed by**: JTGSYSTEMS.COM | JointTechnologyGroup.com
**License**: MIT License
**Repository**: https://github.com/jtgsystems/universal-ollama-optimizer

**Acknowledgments**:
- Jesus Christ - Our Lord and Saviour, for all gifts and abilities
- Ollama Team - For creating an excellent local AI platform
- Community Contributors - For feedback and improvements
- Open Source Community - For tools and inspiration

---

## Resources

### Official Links
- **Repository**: https://github.com/jtgsystems/universal-ollama-optimizer
- **Issues**: https://github.com/jtgsystems/universal-ollama-optimizer/issues
- **Discussions**: https://github.com/jtgsystems/universal-ollama-optimizer/discussions
- **Website**: https://jtgsystems.com

### External Documentation
- **Ollama**: https://ollama.ai/docs
- **Ollama Library**: https://ollama.com/library
- **Bash Guide**: https://tldp.org/LDP/Bash-Beginners-Guide/html/
- **Shellcheck**: https://www.shellcheck.net/

### Community
- **Ollama Discord**: https://discord.gg/ollama
- **Ollama Reddit**: https://reddit.com/r/ollama
- **GitHub Discussions**: Community support and Q&A

---

## License

MIT License - See [LICENSE](LICENSE) file for details.

Copyright (c) 2025 JTGSYSTEMS.COM | JointTechnologyGroup.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

---

**Last Updated**: 2025-01-16
**Maintained by**: JTGSYSTEMS.COM
**For Support**: See [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue
