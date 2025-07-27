# 🚀 EasyProxy3 - The Simplest Proxy Server Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![SystemD](https://img.shields.io/badge/Service-SystemD-blue.svg)](https://systemd.io/)
[![3proxy](https://img.shields.io/badge/Powered%20by-3proxy-orange.svg)](https://github.com/3proxy/3proxy)

> **The easiest, fastest, and most secure way to deploy a production-ready proxy server on any Debian/Ubuntu system in under 60 seconds.**

## ⭐ Why EasyProxy3?

- **🎯 One-Command Setup** - Single script handles everything
- **⚡ Lightning Fast** - Deploys in under 60 seconds
- **🔒 Security First** - Hardened systemd service with dedicated user
- **🛠️ Zero Configuration** - Works out of the box with sane defaults
- **📊 Full Management** - Start, stop, monitor, and configure with ease
- **🔄 Auto-Recovery** - Automatic restart on failures
- **📱 Multi-Protocol** - HTTP & SOCKS5 support built-in

## 🚀 Quick Start

```bash
# Download and run - that's it!
wget -O easyproxy3.sh https://raw.githubusercontent.com/YOUR_USERNAME/easyproxy3/main/easyproxy3.sh
chmod +x easyproxy3.sh
sudo ./easyproxy3.sh install
sudo ./easyproxy3.sh start
```

**🎉 Your proxy is now running!**
- **HTTP Proxy:** `localhost:33033`
- **SOCKS5 Proxy:** `localhost:33034`
- **Username:** `abj`
- **Password:** `Mst123456`

## 📋 Features

### 🔧 **Easy Management**
```bash
./easyproxy3.sh status    # Check service status
./easyproxy3.sh logs      # View logs
./easyproxy3.sh restart   # Restart service
./easyproxy3.sh config    # Edit configuration
```

### 🛡️ **Production Ready**
- ✅ SystemD service integration
- ✅ Automatic startup on boot
- ✅ Dedicated service user (security isolation)
- ✅ Resource limits and monitoring
- ✅ Proper logging and rotation
- ✅ Configuration validation

### 🌐 **Multi-Protocol Support**
- **HTTP/HTTPS Proxy** on port `33033`
- **SOCKS5 Proxy** on port `33034`
- **Authentication** enabled by default
- **Concurrent connections** up to 100

## 📖 Complete Usage Guide

### Installation Commands
```bash
./easyproxy3.sh install   # 📦 Install service (one-time)
./easyproxy3.sh remove    # 🗑️ Completely remove service
```

### Service Management
```bash
./easyproxy3.sh start     # ▶️  Start proxy service
./easyproxy3.sh stop      # ⏹️  Stop proxy service  
./easyproxy3.sh restart   # 🔄 Restart proxy service
./easyproxy3.sh status    # 📊 Show detailed status
./easyproxy3.sh enable    # ✅ Enable auto-start on boot
./easyproxy3.sh disable   # ❌ Disable auto-start
```

### Monitoring & Configuration
```bash
./easyproxy3.sh logs      # 📋 Show recent logs
./easyproxy3.sh follow    # 📈 Follow logs in real-time
./easyproxy3.sh config    # ⚙️ Edit configuration file
./easyproxy3.sh test      # 🧪 Test configuration syntax
```

## 🔧 Configuration

The default configuration is production-ready, but you can customize it:

```bash
sudo ./easyproxy3.sh config
```

**Key configuration options:**
- **Ports:** HTTP (33033), SOCKS5 (33034)
- **Authentication:** Username/password based
- **Logging:** Detailed request logging
- **Security:** Connection limits and timeouts
- **Performance:** Optimized for high throughput

### 📁 File Locations
```
/opt/3proxy/
├── bin/3proxy              # Main binary
├── conf/3proxy.cfg         # Configuration file
├── logs/3proxy.log         # Application logs
└── 3proxy.pid             # Process ID file
```

## 🌍 Use Cases

### 🔒 **Privacy & Security**
- Bypass geo-restrictions
- Secure browsing on public WiFi
- Hide your IP address
- Encrypt web traffic

### 🚀 **Development & Testing**
- Test applications behind proxies
- Simulate different network conditions
- API testing and debugging
- Load balancing setup

### 🏢 **Enterprise & DevOps**
- Internal proxy server
- Network traffic monitoring
- Access control and filtering
- Integration with existing infrastructure

## 🔧 Advanced Configuration

### Custom Ports
Edit `/opt/3proxy/conf/3proxy.cfg`:
```bash
# Change HTTP proxy port
proxy -p8080

# Change SOCKS5 proxy port  
socks -p1080
```

### Multiple Users
```bash
# Add multiple users
users user1:CL:password1
users user2:CL:password2
auth strong
allow user1,user2
```

### IP Restrictions
```bash
# Allow specific IP ranges
allow 192.168.1.0/24
deny *
```

## 🐛 Troubleshooting

### Service Won't Start
```bash
# Check service status
sudo ./easyproxy3.sh status

# View detailed logs
sudo ./easyproxy3.sh logs

# Test configuration
sudo ./easyproxy3.sh test
```

### Common Issues

**Port Already in Use:**
```bash
# Check what's using the port
sudo netstat -tulnp | grep :33033
sudo lsof -i :33033
```

**Permission Denied:**
```bash
# Ensure script is executable
chmod +x easyproxy3.sh

# Run with sudo for system operations
sudo ./easyproxy3.sh start
```

**Service Not Found:**
```bash
# Reinstall the service
sudo ./easyproxy3.sh remove
sudo ./easyproxy3.sh install
```

## 🔒 Security Considerations

### Default Security Features
- ✅ **Isolated Service User** - Runs as dedicated `proxy` user
- ✅ **Filesystem Protection** - Limited write access
- ✅ **Resource Limits** - Prevents resource exhaustion
- ✅ **Authentication Required** - No anonymous access
- ✅ **Connection Limits** - Prevents abuse

### Recommended Security Practices
1. **Change Default Credentials** immediately after installation
2. **Use Strong Passwords** - Mix of letters, numbers, symbols
3. **Limit IP Access** - Restrict to known IP ranges
4. **Monitor Logs** - Regular log review for suspicious activity
5. **Keep Updated** - Regular updates for security patches

### Firewall Configuration
```bash
# Allow proxy ports (adjust as needed)
sudo ufw allow 33033/tcp
sudo ufw allow 33034/tcp

# Or limit to specific IPs
sudo ufw allow from 192.168.1.0/24 to any port 33033
```

## 📊 Performance Tuning

### System Requirements
- **OS:** Debian 9+ / Ubuntu 18.04+
- **RAM:** 256MB minimum, 512MB recommended
- **CPU:** 1 core minimum
- **Storage:** 100MB for installation
- **Network:** Stable internet connection

### Optimization Tips
```bash
# Increase connection limits in config
maxconn 500

# Adjust timeouts for your use case
timeouts 30 60 30 10 3 60 180 1800 15 60

# Monitor resource usage
sudo ./easyproxy3.sh status
htop
```

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **🍴 Fork** the repository
2. **🌟 Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **✅ Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **📤 Push** to the branch (`git push origin feature/amazing-feature`)
5. **🔄 Open** a Pull Request

### 📝 Development Guidelines
- Follow bash best practices
- Add comments for complex logic
- Test on multiple Debian/Ubuntu versions
- Update documentation for new features

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[3proxy](https://github.com/3proxy/3proxy)** - The powerful proxy server engine
- **SystemD** - Modern service management
- **The Open Source Community** - For continuous inspiration

## 📞 Support

- **🐛 Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/easyproxy3/issues)
- **💬 Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/easyproxy3/discussions)
- **📧 Email:** [your-email@domain.com](mailto:your-email@domain.com)

---

<div align="center">

**⭐ If this project helped you, please give it a star! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/easyproxy3.svg?style=social&label=Star)](https://github.com/YOUR_USERNAME/easyproxy3/stargazers)

*Made with ❤️ for the DevOps community*

</div>
