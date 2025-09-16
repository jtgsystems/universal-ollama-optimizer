# Troubleshooting Guide

## Common Issues

### Ollama Not Found
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
```

### Permission Denied
```bash
# Make script executable
chmod +x universal-ollama-optimizer.sh
```

### Model Download Fails
```bash
# Check internet connection and disk space
df -h
ping ollama.ai
```

### GPU Not Detected
```bash
# Check NVIDIA drivers
nvidia-smi
```

### Network Connectivity Issues
The script includes built-in network validation. If network checks fail:
1. Verify internet connection
2. Check DNS resolution: `nslookup ollama.ai`
3. Test connectivity: `curl -Is https://ollama.ai`

### Insufficient System Resources
The script monitors:
- **RAM**: Minimum 8GB recommended
- **Disk Space**: Minimum 5GB free space required
- **GPU Memory**: Automatically detected and displayed

### Error Logs
Check error logs for detailed troubleshooting:
```bash
cat ~/.config/universal-ollama-optimizer/errors.log
```

### Service Issues
If Ollama service fails to start:
```bash
# Check service status
systemctl status ollama

# Restart service
sudo systemctl restart ollama

# Check service logs
journalctl -u ollama -f
```