#!/bin/bash
# Universal Ollama Optimizer - Installation Script

set -e

echo "🚀 Universal Ollama Optimizer - Installation Script"
echo "=================================================="

# Check if running on supported OS
if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script requires Linux or macOS"
    exit 1
fi

# Check for required commands
command -v curl >/dev/null 2>&1 || { echo "❌ Error: curl is required but not installed"; exit 1; }
command -v chmod >/dev/null 2>&1 || { echo "❌ Error: chmod is required but not installed"; exit 1; }

# Download the main script
echo "📥 Downloading Universal Ollama Optimizer..."
curl -fsSL https://raw.githubusercontent.com/your-username/universal-ollama-optimizer/main/universal-ollama-optimizer.sh -o universal-ollama-optimizer.sh

# Make executable
echo "🔧 Making script executable..."
chmod +x universal-ollama-optimizer.sh

# Check if Ollama is installed
if ! command -v ollama >/dev/null 2>&1; then
    echo "⚠️  Ollama not found. Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
else
    echo "✅ Ollama is already installed"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To run the Universal Ollama Optimizer:"
echo "./universal-ollama-optimizer.sh"
echo ""
echo "For help and documentation:"
echo "https://github.com/your-username/universal-ollama-optimizer"