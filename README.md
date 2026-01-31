![Banner](banner.png)

#  Ollama Launcher & Manager

**Developed by [JTGSYSTEMS.COM](https://jtgsystems.com) | [JointTechnologyGroup.com](https://jointtechnologygroup.com)**

A professional bash script for launching and managing Ollama AI models with intelligent profile suggestions, system monitoring, and automated configuration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux-green.svg)](https://github.com/jtgsystems/universal-ollama-optimizer)
[![Ollama](https://img.shields.io/badge/ollama-compatible-orange.svg)](https://ollama.ai)
[![Bash](https://img.shields.io/badge/bash-5.0+-blue.svg)](https://www.gnu.org/software/bash/)

##  What This Actually Does

This is a **model launcher and management toolkit** for Ollama. It provides:

- **Interactive model selection** from 55+ pre-configured 2025 models
- **System validation** before launching (network, Ollama service, disk space, GPU/RAM checks)
- **Parameter profile suggestions** with recommended settings for different use cases
- **Automatic model downloading** with validation and retry logic
- **Clean terminal UI** with colors and progress indicators

### Important Note on "Optimization"

This script **does NOT automatically apply parameters** to models. Ollama's CLI doesn't support passing parameters like `temperature` or `top_p` at launch time. Instead, this tool:

1. **Suggests optimized profiles** based on your use case
2. **Shows you the recommended parameters** for that profile
3. **Provides copy-paste ready `/set` commands** to apply manually during your session

For automatic parameter application, you would need to use Ollama's HTTP API directly or create custom Modelfiles (which this script can help with).

##  Latest Updates (September 2025)

**Added 5 Critical Missing Models Based on Community Research:**
-  **GLM-4** - Ranks 3rd overall on hardcore benchmarks, beats Llama 3 8B
-  **Magicoder** - OSS-Instruct trained coding specialist with 75K synthetic instruction data
-  **Gemma3n** - Multimodal model optimized for everyday devices (phones, tablets, laptops)
-  **Granite 3.3** - IBM's improved models with 128K context (2B and 8B variants)
-  **Gemma3:270M** - Ultra-compact 270M model with 0.75% battery usage on mobile devices

**Enhanced Menu Organization:**
- Expanded model selection from 50+ to 55+ latest 2025 models
- Added new performance benchmarks and descriptions
- Updated all optimization profiles and system recommendations

##  Features

- ** Universal Model Support** - Works with any Ollama model (llama3.2, mistral, gemma2, etc.)
- ** 6 Profile Suggestions** - Pre-configured parameter suggestions: Balanced, Technical, Creative, Code, Reasoning, Roleplay
- ** System Resource Monitoring** - Real-time GPU, RAM, and disk space monitoring
- ** Auto-Download & Validation** - Intelligent model downloading with space checking
- ** Professional Interface** - Clean, colorful terminal UI with progress indicators
- ** Configuration Management** - File-based config with runtime overrides
- ** Custom Parameters** - Full manual parameter control and Modelfile creation
- ** Error Logging** - Comprehensive logging to `~/.config/universal-ollama-optimizer/errors.log`

##  Requirements

- **Linux** (Ubuntu 20.04+, other distros compatible)
- **Bash 5.0+** (pre-installed on most systems)
- **Ollama** ([Download here](https://ollama.ai/download))
- **8GB+ RAM** recommended
- **GPU** optional but recommended (NVIDIA with CUDA support)

##  Quick Start

### One-Command Install & Run
```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/jtgsystems/universal-ollama-optimizer/main/universal-ollama-optimizer.sh -o universal-ollama-optimizer.sh
chmod +x universal-ollama-optimizer.sh
./universal-ollama-optimizer.sh
```

### Manual Installation
```bash
# Clone repository
git clone https://github.com/jtgsystems/universal-ollama-optimizer.git
cd universal-ollama-optimizer

# Make executable
chmod +x universal-ollama-optimizer.sh

# Run
./universal-ollama-optimizer.sh
```

##  Usage

### Interactive Mode (Default)
```bash
./universal-ollama-optimizer.sh
```

1. **Select Model** - Choose from available models or enter new model name
2. **Choose Profile** - Select parameter suggestion profile (1-9)
3. **Launch Model** - Model starts with parameter instructions displayed
4. **Apply Parameters** - Use `/set` commands manually during the session

### Example Session
```
Enter model name: llama3.2:latest

Model Information:
  • Model: llama3.2:latest
  • Size: 4.7GB
  • Parameters: 3.2B

System Status:
  • GPU Memory: 16380 MB
  • System RAM: 32GB
  • Available Disk: 150GB

Parameter Profiles:
  1) Balanced          - General purpose (temp: 0.5)
  2) Technical/Factual - Precise answers (temp: 0.2)
  3) Creative Writing  - Imaginative content (temp: 1.0)
  4) Code Generation   - Programming tasks (temp: 0.15)
  5) Reasoning/Logic   - Problem solving (temp: 0.3)
  6) Roleplay/Chat     - Conversational (temp: 0.8)

Select profile [1-6]: 1

Starting llama3.2:latest with Balanced profile suggestion...

To apply these parameters during your session, use:
/set parameter temperature 0.5
/set parameter top_p 0.85
/set parameter top_k 30
/set parameter repeat_penalty 1.08
```

##  Configuration

### Config File Location
```
~/.config/universal-ollama-optimizer/config.conf
```

### Example Configuration
```ini
# Default profile (balanced, technical, creative, code, reasoning, roleplay)
DEFAULT_PROFILE="balanced"

# Auto-start Ollama service if not running
AUTO_START_OLLAMA=true

# System monitoring
SHOW_SYSTEM_INFO=true
SHOW_GPU_INFO=true

# Download settings
DOWNLOAD_TIMEOUT=1800
MIN_DISK_SPACE_GB=5
```

##  Parameter Profiles (Suggestions)

| Profile | Temperature | Top-P | Top-K | Best For |
|---------|-------------|-------|-------|----------|
| **Balanced** | 0.5 | 0.85 | 30 | General use, Q&A |
| **Technical** | 0.2 | 0.8 | 20 | Documentation, facts |
| **Creative** | 1.0 | 0.95 | 50 | Stories, brainstorming |
| **Code** | 0.15 | 0.7 | 15 | Programming, debugging |
| **Reasoning** | 0.3 | 0.75 | 25 | Logic, analysis |
| **Roleplay** | 0.8 | 0.9 | 40 | Character chat |

##  Advanced Features

### Custom Parameters
Choose option `7` for manual parameter configuration:
- Temperature (0.0-2.0)
- Top-P (0.0-1.0)
- Top-K (1-100)
- Context length
- Max tokens per response
- Repeat penalty

### Modelfile Creation
Choose option `8` to create and save custom model configurations:
```bash
# Creates permanent optimized model variants
# Example: llama3.2-coding, mistral-creative
```

### Runtime Commands
Once model is running, use these commands:
```bash
/set parameter temperature 0.7    # Adjust parameters
/set system "You are a coding assistant"  # Change system prompt
/show parameters                  # View current settings
/save my-conversation            # Save session
/load my-conversation            # Load session
```

##  Troubleshooting

### Common Issues

**Ollama Not Found**
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
```

**Permission Denied**
```bash
# Make script executable
chmod +x universal-ollama-optimizer.sh
```

**Model Download Fails**
```bash
# Check internet connection and disk space
df -h
ping ollama.ai
```

**GPU Not Detected**
```bash
# Check NVIDIA drivers
nvidia-smi
```

##  Project Structure

```
universal-ollama-optimizer/
├── universal-ollama-optimizer.sh    # Main script
├── README.md                        # This file
├── LICENSE                          # MIT License
└── .github/
    ├── workflows/
    │   └── test.yml                 # CI/CD tests
    ├── ISSUE_TEMPLATE/              # Issue templates
    └── PULL_REQUEST_TEMPLATE.md     # PR template
```

##  Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup
```bash
# Fork and clone
git clone https://github.com/jtgsystems/universal-ollama-optimizer.git
cd universal-ollama-optimizer

# Test the script
./universal-ollama-optimizer.sh

# Run with debug mode
bash -x universal-ollama-optimizer.sh
```

### Reporting Issues
- Use the [issue tracker](https://github.com/jtgsystems/universal-ollama-optimizer/issues)
- Include OS version, Ollama version, and error messages
- Provide steps to reproduce

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Acknowledgments

- **Jesus Christ** - Our Lord and Saviour, for all gifts and abilities
- **Ollama Team** - For creating an excellent local AI platform
- **Community Contributors** - For feedback and improvements
- **JTGSYSTEMS.COM** - For development and maintenance

##  Support

- **Issues**: [GitHub Issues](https://github.com/jtgsystems/universal-ollama-optimizer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jtgsystems/universal-ollama-optimizer/discussions)
- **Website**: [JTGSYSTEMS.COM](https://jtgsystems.com)

---

##  Recommended Ollama Models (September 2025)

*Based on latest community recommendations and performance benchmarks*

### ** Top-Tier Models (September 2025)**

#### ** Best Overall Performance**
- **`llama3.3:70b`** - Meta's flagship 2025 model, rivals GPT-4 performance locally
- **`glm4:latest`**  - Ranks 3rd overall, beats Llama 3 8B in benchmarks
- **`llama3.1:8b`** - Community favorite, best balance of performance and efficiency
- **`llama3.1:70b`** - High-performance for complex reasoning and enterprise use
- **`deepseek-r1`** - Powerhouse for deep logical reasoning and analysis

#### ** Premier Coding Models**
- **`deepseek-coder:33b`** - #1 coding model, excels at complex programming tasks
- **`magicoder:latest`**  - OSS-Instruct trained specialist, 75K synthetic data
- **`qwen3-coder:30b`** - Alibaba's latest 2025 coding model with major improvements
- **`codellama:34b`** - Meta's specialized coding model with excellent context understanding
- **`qwen2.5-coder:32b`** - Previous Alibaba model with solid code generation

#### ** Resource-Efficient Champions**
- **`granite3.3:8b`**  - IBM's improved model with 128K context, rivals Llama 3.1
- **`mistral:7b-instruct`** - Community-recommended for beginners, excellent performance/resource ratio
- **`phi4:14b`** - Microsoft's 2025 state-of-the-art efficiency model
- **`granite3.3:2b`**  - IBM's efficient enterprise model for edge deployment
- **`llama3.2:3b`** - Compact Llama for lightweight deployments
- **`gemma3:270m`**  - Ultra-compact 270M model, 0.75% battery usage on mobile
- **`gemma2:9b`** - Google's efficient model, great for general tasks

#### ** Creative & Multimodal**
- **`gemma3n:latest`**  - Multimodal optimized for everyday devices (phones, tablets)
- **`llava:latest`** - Leading vision model for image analysis and VQA
- **`qwen-vl`** - Advanced multimodal model for document and image processing
- **`gemma2:27b`** - Excellent for creative writing and content generation

### ** Performance Matrix (September 2025)**

| Use Case | Top Model | Alternative | RAM Required | Best Profile |
|----------|-----------|-------------|--------------|--------------|
| **General Chat** | `llama3.3:70b` | `glm4:latest`  | 64GB / 9GB | Balanced |
| **Code Development** | `deepseek-coder:33b` | `magicoder:latest`  | 32GB / 7GB | Code |
| **Reasoning Tasks** | `deepseek-r1` | `glm4:latest`  | 16GB / 9GB | Reasoning |
| **Creative Writing** | `gemma2:27b` | `gemma3n:latest`  | 32GB / 8GB | Creative |
| **Resource-Limited** | `granite3.3:2b`  | `gemma3:270m`  | 2GB / 300MB | Balanced |
| **Vision/Multimodal** | `llava:latest` | `gemma3n:latest`  | 16GB / 8GB | Technical |
| **Enterprise/128K Context** | `granite3.3:8b`  | `llama3.1:8b` | 8GB | Technical |
| **Edge/Mobile** | `gemma3:270m`  | `granite3.3:2b`  | 300MB / 2GB | Balanced |

### ** Quick Download Commands (September 2025)**
```bash
# Most recommended overall (2025 flagship)
ollama pull llama3.3:70b-instruct

# High-performance alternative (ranks 3rd overall)
ollama pull glm4:latest

# Specialized coding assistant with OSS-Instruct training
ollama pull magicoder:latest

# Premier coding powerhouse
ollama pull deepseek-coder:33b

# Enterprise model with 128K context
ollama pull granite3.3:8b

# Ultra-efficient for mobile/edge (270M parameters)
ollama pull gemma3:270m

# Multimodal for everyday devices
ollama pull gemma3n:latest

# Advanced reasoning powerhouse
ollama pull deepseek-r1

# Vision and image analysis
ollama pull llava:latest

# Best for beginners/limited hardware
ollama pull mistral:7b-instruct
```

### ** 2025 Community Insights**
- **Llama 3.3** has become the gold standard for local deployment
- **DeepSeek models** dominate coding and reasoning benchmarks
- **Mistral 7B** remains the go-to recommendation for newcomers
- **Vision models** like LLaVA are gaining massive adoption
- Over **1,700+ models** now available in Ollama ecosystem

*Note: Model availability and performance may vary. Check [ollama.com/library](https://ollama.com/library) for the latest models.*

---

**Repository**: `universal-ollama-optimizer` | **Developer**: JTGSYSTEMS.COM | **Technology**: Bash, Linux, Ollama, AI
