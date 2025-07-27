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
