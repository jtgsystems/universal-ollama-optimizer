#!/bin/bash
# Basic usage examples for Universal Ollama Optimizer

echo "=== Universal Ollama Optimizer - Basic Usage Examples ==="

# Example 1: Run with interactive model selection
echo "1. Interactive mode (default):"
echo "./universal-ollama-optimizer.sh"
echo ""

# Example 2: Debug mode for troubleshooting
echo "2. Debug mode for troubleshooting:"
echo "DEBUG_MODE=true ./universal-ollama-optimizer.sh"
echo ""

# Example 3: Check system status only
echo "3. System validation check:"
echo "./universal-ollama-optimizer.sh --check"
echo ""

# Example 4: View error logs
echo "4. View error logs:"
echo "cat ~/.config/universal-ollama-optimizer/errors.log"
echo ""

# Example 5: Common model selections
echo "5. Popular model recommendations:"
echo "   - llama3.3:70b (Best overall performance)"
echo "   - deepseek-coder:33b (Best for coding)"
echo "   - mistral:7b-instruct (Best for beginners)"
echo "   - glm4:latest (High performance alternative)"
echo ""

echo "=== System Requirements Check ==="
echo "Run the optimizer to automatically verify:"
echo "- Network connectivity"
echo "- Ollama installation"
echo "- System resources (RAM/Disk/GPU)"
echo "- Model availability"