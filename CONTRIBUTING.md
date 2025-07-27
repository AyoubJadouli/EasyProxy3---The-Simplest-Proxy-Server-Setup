# 🤝 Contributing to EasyProxy3

Thank you for your interest in contributing to EasyProxy3! This document provides guidelines and information for contributors.

## 🚀 Quick Start for Contributors

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/easyproxy3.git
   cd easyproxy3
   ```
3. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** and test thoroughly
5. **Commit and push** your changes
6. **Submit a Pull Request**

## 📋 Development Guidelines

### 🛠️ Code Standards

**Bash Scripting Best Practices:**
- Use `set -e` for error handling
- Quote variables: `"${variable}"` instead of `$variable`
- Use meaningful function and variable names
- Add comments for complex logic
- Use shellcheck for linting

**Example:**
```bash
# ✅ Good
check_service_status() {
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
        echo "Service is running"
        return 0
    else
        echo "Service is not running"
        return 1
    fi
}

# ❌ Avoid
check() {
    systemctl is-active $1 && echo ok || echo bad
}
```

### 🧪 Testing Requirements

Before submitting a PR, ensure your changes work on:
- **Ubuntu 20.04 LTS** (minimum)
- **Ubuntu 22.04 LTS** 
- **Debian 11** (minimum)
- **Debian 12**

**Test scenarios:**
```bash
# Fresh installation
./easyproxy3.sh install
./easyproxy3.sh start
./easyproxy3.sh status

# Configuration changes
./easyproxy3.sh config
./easyproxy3.sh test
./easyproxy3.sh restart

# Service management
./easyproxy3.sh stop
./easyproxy3.sh disable
./easyproxy3.sh enable
./easyproxy3.sh start

# Cleanup
./easyproxy3.sh remove
```

### 📝 Documentation

- Update README.md for new features
- Add inline comments for complex functions
- Include usage examples
- Update configuration documentation

## 🎯 Types of Contributions

### 🐛 Bug Fixes
- Include steps to reproduce the issue
- Test the fix on multiple systems
- Add regression tests if applicable

### ✨ New Features
- Discuss major features in an issue first
- Maintain backward compatibility
- Update documentation
- Add configuration examples

### 📚 Documentation
- Fix typos and grammar
- Improve clarity and examples
- Add troubleshooting guides
- Translate to other languages

### 🔧 Infrastructure
- Improve CI/CD workflows
- Add automated testing
- Performance optimizations
- Security enhancements

## 📋 Pull Request Process

### ✅ Before Submitting

1. **Test thoroughly** on supported systems
2. **Run shellcheck** on bash scripts:
   ```bash
   shellcheck easyproxy3.sh
   ```
3. **Update documentation** as needed
4. **Add yourself** to contributors list

### 📝 PR Description Template

```markdown
## 🎯 What does this PR do?
Brief description of the changes

## 🧪 Testing
- [ ] Tested on Ubuntu 20.04
- [ ] Tested on Ubuntu 22.04  
- [ ] Tested on Debian 11
- [ ] Tested fresh installation
- [ ] Tested service management
- [ ] Tested configuration changes

## 📋 Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Backward compatibility maintained
- [ ] No breaking changes (or clearly documented)

## 🔗 Related Issues
Fixes #issue_number
```

### 🔍 Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Testing** on different environments
4. **Documentation review**
5. **Final approval** and merge

## 🏷️ Issue Guidelines

### 🐛 Bug Reports

Use this template:
```markdown
**🐛 Bug Description**
Clear description of the bug

**🔄 Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**💻 Environment**
- OS: Ubuntu 22.04
- Script version: v1.0.0
- Command used: ./easyproxy3.sh start

**📋 Expected vs Actual**
- Expected: Service should start
- Actual: Service fails with error

**📎 Additional Context**
Logs, screenshots, or other context
```

### 💡 Feature Requests

Use this template:
```markdown
**🎯 Feature Description**
Clear description of the requested feature

**🤔 Use Case**
Why is this feature needed?

**💭 Proposed Solution**
How should this work?

**🔄 Alternatives Considered**
Other approaches you've thought about

**📋 Additional Context**
Any other relevant information
```

## 🎨 Code Style

### 🎯 Naming Conventions

```bash
# Variables: lowercase with underscores
service_name="3proxy"
config_dir="/opt/3proxy/conf"

# Functions: lowercase with underscores
install_service() { ... }
check_system_requirements() { ... }

# Constants: uppercase with underscores
readonly VERSION="0.9.4"
readonly SERVICE_NAME="3proxy"
```

### 🏗️ Function Structure

```bash
function_name() {
    # Brief description of what this function does
    local param1="$1"
    local param2="$2"
    
    # Validation
    if [[ -z "${param1}" ]]; then
        echo "Error: param1 is required"
        return 1
    fi
    
    # Main logic
    echo "Processing ${param1}..."
    
    # Return status
    return 0
}
```

### 📊 Error Handling

```bash
# Always check command success
if ! systemctl start "${SERVICE_NAME}"; then
    echo "❌ Failed to start service"
    return 1
fi

# Use meaningful error messages
if [[ ! -f "${config_file}" ]]; then
    echo "❌ Configuration file not found: ${config_file}"
    echo "💡 Run: $(basename "$0") install"
    exit 1
fi
```

## 🔒 Security Guidelines

### 🛡️ Security Best Practices

- **Never hardcode secrets** in the script
- **Validate all inputs** before processing
- **Use safe temporary files** with proper permissions
- **Follow principle of least privilege**
- **Audit file permissions** regularly

### 🔍 Security Review Checklist

- [ ] No hardcoded passwords or keys
- [ ] Input validation implemented
- [ ] File permissions are restrictive
- [ ] No shell injection vulnerabilities
- [ ] Service runs as non-root user
- [ ] Network exposure is minimal

## 🏆 Recognition

Contributors are recognized in:
- **README.md** contributors section
- **Release notes** for significant contributions
- **GitHub contributors** page

## 📞 Getting Help

- **💬 Discussions:** Use GitHub Discussions for questions
- **🐛 Issues:** Report bugs via GitHub Issues
- **📧 Direct Contact:** For security issues only

## 📚 Resources

- **[Bash Style Guide](https://google.github.io/styleguide/shellguide.html)**
- **[SystemD Documentation](https://systemd.io/)**
- **[3proxy Documentation](https://github.com/3proxy/3proxy)**
- **[Semantic Versioning](https://semver.org/)**

---

**Thank you for contributing to EasyProxy3! 🙏**
