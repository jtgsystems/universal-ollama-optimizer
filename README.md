# 🚀 Universal Ollama Optimizer

**Developed by [JTGSYSTEMS.COM](https://jtgsystems.com) | [JointTechnologyGroup.com](https://jointtechnologygroup.com)**

A professional bash script for launching and optimizing any Ollama AI model with intelligent profiles, system monitoring, and automated configuration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux-green.svg)](https://github.com/your-username/universal-ollama-optimizer)
[![Ollama](https://img.shields.io/badge/ollama-compatible-orange.svg)](https://ollama.ai)
[![Bash](https://img.shields.io/badge/bash-5.0+-blue.svg)](https://www.gnu.org/software/bash/)

## ✨ Features

- **🎯 Universal Model Support** - Works with any Ollama model (llama3.2, mistral, gemma2, etc.)
- **⚙️ Smart Optimization Profiles** - 6 pre-configured profiles: Balanced, Technical, Creative, Code, Reasoning, Roleplay
- **📊 System Resource Monitoring** - Real-time GPU, RAM, and disk space monitoring
- **🚀 Auto-Download & Validation** - Intelligent model downloading with space checking
- **🎨 Professional Interface** - Clean, colorful terminal UI with progress indicators
- **⚡ Configuration Management** - File-based config with runtime overrides
- **🔧 Custom Parameters** - Full manual parameter control and Modelfile creation

## 📋 Requirements

- **Linux** (Ubuntu 20.04+, other distros compatible)
- **Bash 5.0+** (pre-installed on most systems)
- **Ollama** ([Download here](https://ollama.ai/download))
- **8GB+ RAM** recommended
- **GPU** optional but recommended (NVIDIA with CUDA support)

## 🚀 Quick Start

### One-Command Install & Run
```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/your-username/universal-ollama-optimizer/main/universal-ollama-optimizer.sh -o universal-ollama-optimizer.sh
chmod +x universal-ollama-optimizer.sh
./universal-ollama-optimizer.sh
```

### Manual Installation
```bash
# Clone repository
git clone https://github.com/your-username/universal-ollama-optimizer.git
cd universal-ollama-optimizer

# Make executable
chmod +x universal-ollama-optimizer.sh

# Run
./universal-ollama-optimizer.sh
```

## 📖 Usage

### Interactive Mode (Default)
```bash
./universal-ollama-optimizer.sh
```

1. **Select Model** - Choose from available models or enter new model name
2. **Choose Profile** - Select optimization profile (1-9)
3. **Launch Model** - Model starts with optimized settings

### Example Session
```
╔════════════════════════════════════════════╗
║         Universal Ollama Optimizer        ║
║      JTGSYSTEMS.COM | JointTechnologyGroup ║
╚════════════════════════════════════════════╝

✓ Ollama service is running

Available Local Models:
  • llama3.2:latest (4.7GB)
  • mistral:7b (4.1GB)
  • gemma2:9b (5.4GB)

Enter model name: llama3.2:latest

Model Information:
  • Model: llama3.2:latest
  • Size: 4.7GB
  • Parameters: 3.2B

System Status:
  • GPU Memory: 16380 MB
  • System RAM: 32GB
  • Available Disk: 150GB

Optimization Profiles:
  1) Balanced          - General purpose (temp: 0.5)
  2) Technical/Factual - Precise answers (temp: 0.2)
  3) Creative Writing  - Imaginative content (temp: 1.0)
  4) Code Generation   - Programming tasks (temp: 0.15)
  5) Reasoning/Logic   - Problem solving (temp: 0.3)
  6) Roleplay/Chat     - Conversational (temp: 0.8)

Select profile [1-6]: 1

Starting llama3.2:latest with Balanced profile...
```

## ⚙️ Configuration

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

## 🎯 Optimization Profiles

| Profile | Temperature | Top-P | Top-K | Best For |
|---------|-------------|-------|-------|----------|
| **Balanced** | 0.5 | 0.85 | 30 | General use, Q&A |
| **Technical** | 0.2 | 0.8 | 20 | Documentation, facts |
| **Creative** | 1.0 | 0.95 | 50 | Stories, brainstorming |
| **Code** | 0.15 | 0.7 | 15 | Programming, debugging |
| **Reasoning** | 0.3 | 0.75 | 25 | Logic, analysis |
| **Roleplay** | 0.8 | 0.9 | 40 | Character chat |

## 🛠️ Advanced Features

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

## 🚨 Troubleshooting

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

## 📁 Project Structure

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

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup
```bash
# Fork and clone
git clone https://github.com/your-username/universal-ollama-optimizer.git
cd universal-ollama-optimizer

# Test the script
./universal-ollama-optimizer.sh

# Run with debug mode
bash -x universal-ollama-optimizer.sh
```

### Reporting Issues
- Use the [issue tracker](https://github.com/your-username/universal-ollama-optimizer/issues)
- Include OS version, Ollama version, and error messages
- Provide steps to reproduce

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Jesus Christ** - Our Lord and Saviour, for all gifts and abilities
- **Ollama Team** - For creating an excellent local AI platform
- **Community Contributors** - For feedback and improvements
- **JTGSYSTEMS.COM** - For development and maintenance

## 📈 Stars History

[![Star History Chart](https://api.star-history.com/svg?repos=your-username/universal-ollama-optimizer&type=Date)](https://star-history.com/#your-username/universal-ollama-optimizer&Date)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/universal-ollama-optimizer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/universal-ollama-optimizer/discussions)
- **Website**: [JTGSYSTEMS.COM](https://jtgsystems.com)

---

## 🤖 Recommended Ollama Models (2025)

### **Latest & Most Capable Models**

#### **🧠 General Purpose & Reasoning**
- **`llama3.1:8b`** - Meta's latest 8B model, excellent balance of performance and efficiency
- **`llama3.1:70b`** - High-performance 70B model for complex reasoning tasks
- **`deepseek-r1:7b`** - Advanced reasoning model, excellent for logic and analysis
- **`qwen3:8b`** - Alibaba's latest model with strong multilingual capabilities

#### **💻 Code Generation & Programming**
- **`deepseek-coder:33b`** - Premier coding model for complex programming tasks
- **`codellama:34b`** - Meta's specialized coding model, excellent context understanding
- **`qwen2.5-coder:32b`** - Multi-language development powerhouse

#### **⚡ Lightweight & Efficient**
- **`gemma3:2b`** - Google's compact yet powerful model (requires only 4GB RAM)
- **`phi3:3.8b`** - Microsoft's efficient model, great for edge devices
- **`llama3.2:3b`** - Compact version of Llama for resource-constrained systems

#### **🎨 Creative & Conversational**
- **`gemma3:9b`** - Excellent for creative writing and dialogue
- **`mistral:7b`** - Well-balanced model for general conversation
- **`llama3.1:8b`** - Versatile for both creative and technical tasks

### **Model Selection Guide**

| Use Case | Recommended Model | RAM Required | Best Profile |
|----------|------------------|--------------|--------------|
| **General Chat** | `llama3.1:8b` | 8GB | Balanced |
| **Code Development** | `deepseek-coder:33b` | 32GB | Code |
| **Creative Writing** | `gemma3:9b` | 16GB | Creative |
| **Technical Analysis** | `deepseek-r1:7b` | 8GB | Technical |
| **Lightweight Tasks** | `phi3:3.8b` | 4GB | Balanced |
| **Multilingual** | `qwen3:8b` | 8GB | Balanced |

### **Quick Download Commands**
```bash
# Most popular general-purpose model
ollama pull llama3.1:8b

# Best coding assistant
ollama pull deepseek-coder:33b

# Lightweight for older hardware
ollama pull phi3:3.8b

# Creative writing specialist
ollama pull gemma3:9b

# Advanced reasoning
ollama pull deepseek-r1:7b
```

*Note: Model availability and performance may vary. Check [ollama.com/library](https://ollama.com/library) for the latest models.*

## 🔍 SEO Keywords & Search Terms

### **Primary Keywords**
ollama optimizer, ollama launcher, universal ollama, ollama bash script, ollama automation, ollama profiles, ollama configuration, ollama setup, local AI, AI model launcher

### **Technical Keywords**
ollama cli, ollama command line, ollama parameters, ollama temperature, ollama top-p, ollama top-k, bash automation, linux ollama, model optimization, AI model tuning, LLM parameters

### **Use Case Keywords**
ollama for developers, code generation optimizer, creative writing AI, AI assistant launcher, local chatbot, offline AI, private AI, self-hosted LLM, enterprise AI solution

### **Long-tail Keywords**
how to optimize ollama models, best ollama configuration, ollama performance tuning, local AI model management, automated ollama setup, ollama bash automation script

**Repository**: `universal-ollama-optimizer` | **Developer**: JTGSYSTEMS.COM | **Technology**: Bash, Linux, Ollama, AI