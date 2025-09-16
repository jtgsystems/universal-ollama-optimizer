# Contributing to Universal Ollama Optimizer

Thank you for your interest in contributing to Universal Ollama Optimizer! We welcome contributions from the community.

## 🚀 Ways to Contribute

- **Bug Reports** - Report issues with detailed steps to reproduce
- **Feature Requests** - Suggest new features or improvements
- **Code Contributions** - Submit pull requests with enhancements
- **Documentation** - Improve README, add examples, or write tutorials
- **Testing** - Test on different systems and report compatibility

## 🛠️ Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/universal-ollama-optimizer.git
   cd universal-ollama-optimizer
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** and test thoroughly
5. **Commit your changes**:
   ```bash
   git commit -m "Add your descriptive commit message"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request** on GitHub

## 📝 Code Guidelines

### Bash Script Standards
- Use proper error handling with `set -euo pipefail`
- Include descriptive comments for complex logic
- Follow existing variable naming conventions
- Test on multiple Linux distributions
- Ensure compatibility with Bash 5.0+

### Commit Message Format
```
type(scope): brief description

Detailed explanation of the changes (if needed)

Fixes #issue-number
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Example
```
feat(profiles): add new reasoning profile for logical tasks

- Added temperature 0.3 configuration
- Optimized top-p and top-k values
- Updated profile selection menu

Fixes #123
```

## 🧪 Testing

Before submitting a PR:

1. **Test the script** on your system:
   ```bash
   ./universal-ollama-optimizer.sh
   ```

2. **Test with different models** (if available):
   ```bash
   # Test with small models like gemma:2b
   ```

3. **Check for bash syntax errors**:
   ```bash
   bash -n universal-ollama-optimizer.sh
   ```

4. **Test with shellcheck** (if available):
   ```bash
   shellcheck universal-ollama-optimizer.sh
   ```

## 🐛 Bug Reports

When reporting bugs, please include:

- **Operating System** and version
- **Bash version** (`bash --version`)
- **Ollama version** (`ollama --version`)
- **Model being used**
- **Complete error message**
- **Steps to reproduce** the issue

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).

## 💡 Feature Requests

For feature requests:

- **Describe the problem** you're trying to solve
- **Explain your proposed solution**
- **Consider implementation complexity**
- **Provide use cases** and examples

Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Test your changes thoroughly
- [ ] Update documentation if needed
- [ ] Follow the existing code style
- [ ] Add comments for complex logic
- [ ] Ensure backward compatibility

### PR Description
- **Clear title** describing the change
- **Detailed description** of what was changed and why
- **Testing performed** and results
- **Breaking changes** (if any)
- **Related issues** (reference with #issue-number)

## 🔄 Review Process

1. **Automated checks** will run on your PR
2. **Maintainers will review** your code
3. **Feedback will be provided** if changes are needed
4. **Approval and merge** once everything looks good

## 📚 Resources

- [Bash Scripting Guide](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [Ollama Documentation](https://ollama.ai/docs)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

## 🤝 Code of Conduct

Please be respectful and constructive in all interactions. We're building this tool together for the benefit of the local AI community.

## 🆘 Getting Help

- **GitHub Discussions** - For questions and general discussion
- **GitHub Issues** - For bug reports and feature requests
- **Email** - Contact JTGSYSTEMS.COM for urgent matters

Thank you for contributing to Universal Ollama Optimizer! 🚀