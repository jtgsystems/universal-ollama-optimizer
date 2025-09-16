# Installation Guide

## Quick Installation

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

## Prerequisites

- **Linux** (Ubuntu 20.04+, other distros compatible)
- **Bash 5.0+** (pre-installed on most systems)
- **Ollama** ([Download here](https://ollama.ai/download))
- **8GB+ RAM** recommended
- **GPU** optional but recommended (NVIDIA with CUDA support)

## Verification

After installation, the script will automatically:
- Check network connectivity
- Verify Ollama installation and service status
- Monitor system resources (RAM, disk space, GPU)
- Create configuration directory at `~/.config/universal-ollama-optimizer/`

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.