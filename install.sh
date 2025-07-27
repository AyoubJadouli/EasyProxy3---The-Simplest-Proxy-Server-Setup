#!/usr/bin/env bash
set -e

# 🚀 EasyProxy3 Quick Installer
# One-liner installation script for maximum convenience

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/easyproxy3/main"
SCRIPT_NAME="easyproxy3.sh"
INSTALL_DIR="/usr/local/bin"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                        🚀 EasyProxy3 Installer                   ║"
    echo "║                                                                  ║"
    echo "║           The Easiest Proxy Server Setup in 60 Seconds          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_requirements() {
    echo -e "${BLUE}🔍 Checking system requirements...${NC}"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ This installer must be run as root (use sudo)${NC}"
        exit 1
    fi
    
    # Check OS
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}❌ Cannot detect OS. This installer supports Debian/Ubuntu only.${NC}"
        exit 1
    fi
    
    source /etc/os-release
    if [[ ! "$ID" =~ ^(ubuntu|debian)$ ]]; then
        echo -e "${RED}❌ Unsupported OS: $ID. This installer supports Debian/Ubuntu only.${NC}"
        exit 1
    fi
    
    # Check systemd
    if ! command -v systemctl &> /dev/null; then
        echo -e "${RED}❌ SystemD not found. This installer requires SystemD.${NC}"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ No internet connection. Please check your network.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All requirements met${NC}"
}

download_script() {
    echo -e "${BLUE}📦 Downloading EasyProxy3...${NC}"
    
    local temp_script="/tmp/${SCRIPT_NAME}"
    
    # Try wget first, then curl
    if command -v wget &> /dev/null; then
        if wget -q -O "${temp_script}" "${REPO_URL}/${SCRIPT_NAME}"; then
            echo -e "${GREEN}✅ Downloaded successfully${NC}"
        else
            echo -e "${RED}❌ Download failed with wget${NC}"
            exit 1
        fi
    elif command -v curl &> /dev/null; then
        if curl -sL -o "${temp_script}" "${REPO_URL}/${SCRIPT_NAME}"; then
            echo -e "${GREEN}✅ Downloaded successfully${NC}"
        else
            echo -e "${RED}❌ Download failed with curl${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Neither wget nor curl found. Please install one of them.${NC}"
        exit 1
    fi
    
    # Verify download
    if [[ ! -f "${temp_script}" ]] || [[ ! -s "${temp_script}" ]]; then
        echo -e "${RED}❌ Downloaded file is empty or missing${NC}"
        exit 1
    fi
    
    # Move to system location
    mv "${temp_script}" "${INSTALL_DIR}/${SCRIPT_NAME}"
    chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
    
    echo -e "${GREEN}✅ EasyProxy3 installed to ${INSTALL_DIR}/${SCRIPT_NAME}${NC}"
}

install_proxy() {
    echo -e "${BLUE}🔧 Installing proxy service...${NC}"
    
    if "${INSTALL_DIR}/${SCRIPT_NAME}" install; then
        echo -e "${GREEN}✅ Proxy service installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install proxy service${NC}"
        exit 1
    fi
}

start_proxy() {
    echo -e "${BLUE}▶️ Starting proxy service...${NC}"
    
    # Enable auto-start
    if "${INSTALL_DIR}/${SCRIPT_NAME}" enable; then
        echo -e "${GREEN}✅ Auto-start enabled${NC}"
    else
        echo -e "${YELLOW}⚠️ Failed to enable auto-start${NC}"
    fi
    
    # Start service
    if "${INSTALL_DIR}/${SCRIPT_NAME}" start; then
        echo -e "${GREEN}✅ Proxy service started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start proxy service${NC}"
        exit 1
    fi
}

show_completion() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 Installation Complete!                     ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}📋 Your proxy server is now running:${NC}"
    echo -e "${GREEN}   • HTTP Proxy:   localhost:33033${NC}"
    echo -e "${GREEN}   • SOCKS5 Proxy: localhost:33034${NC}"
    echo -e "${GREEN}   • Username:     proxyuser${NC}"
    echo -e "${GREEN}   • Password:     ChangeMe123!${NC}"
    echo ""
    echo -e "${CYAN}🔧 Management commands:${NC}"
    echo -e "${YELLOW}   ${SCRIPT_NAME} status    ${NC}# Check service status"
    echo -e "${YELLOW}   ${SCRIPT_NAME} logs      ${NC}# View logs"
    echo -e "${YELLOW}   ${SCRIPT_NAME} restart   ${NC}# Restart service"
    echo -e "${YELLOW}   ${SCRIPT_NAME} config    ${NC}# Edit configuration"
    echo -e "${YELLOW}   ${SCRIPT_NAME} stop      ${NC}# Stop service"
    echo ""
    echo -e "${CYAN}📚 Full documentation:${NC}"
    echo -e "${YELLOW}   https://github.com/YOUR_USERNAME/easyproxy3${NC}"
    echo ""
    echo -e "${BLUE}🧪 Test your proxy:${NC}"
    echo -e "${YELLOW}   curl -x http://proxyuser:ChangeMe123!@localhost:33033 http://httpbin.org/ip${NC}"
    echo ""
}

show_usage() {
    echo "🚀 EasyProxy3 Quick Installer"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --auto          Run fully automated installation"
    echo "  --help, -h      Show this help message"
    echo "  --version, -v   Show version information"
    echo ""
    echo "Examples:"
    echo "  sudo $0                    # Interactive installation"
    echo "  sudo $0 --auto            # Automated installation"
    echo ""
}

show_version() {
    echo "EasyProxy3 Quick Installer v1.0.0"
    echo "Copyright (c) 2025 EasyProxy3 Contributors"
    echo "Licensed under MIT License"
}

main() {
    local auto_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                auto_mode=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_banner
    
    if [[ "$auto_mode" == false ]]; then
        echo -e "${YELLOW}⚠️ This will install and configure a proxy server on your system.${NC}"
        echo -e "${YELLOW}   The installation will:${NC}"
        echo -e "${YELLOW}   • Download and install 3proxy binary${NC}"
        echo -e "${YELLOW}   • Create a system service${NC}"
        echo -e "${YELLOW}   • Configure HTTP (port 33033) and SOCKS5 (port 33034) proxies${NC}"
        echo -e "${YELLOW}   • Start the service automatically${NC}"
        echo ""
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
    
    check_requirements
    download_script
    install_proxy
    start_proxy
    show_completion
}

# Trap errors
trap 'echo -e "${RED}❌ Installation failed at line $LINENO${NC}"; exit 1' ERR

# Run main function
main "$@"
