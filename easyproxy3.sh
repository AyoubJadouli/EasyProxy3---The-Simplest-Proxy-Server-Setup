#!/usr/bin/env bash
set -e

# ⚙️ EasyProxy3 Complete Service Manager & Installer
# Handles installation, management, and configuration

# ---------------------------------------------------------
# CONFIGURATION VARIABLES
# ---------------------------------------------------------
VERSION="0.9.4"
ARCH="x86_64"
# 🔒 SECURITY: Using secure default credentials - CHANGE IMMEDIATELY AFTER INSTALL!
USERNAME="proxyuser"
PASSWORD="ChangeMe123!"

# System directories
TARGET_DIR="/opt/3proxy"
BIN_DIR="${TARGET_DIR}/bin"
LIBEXEC_DIR="${TARGET_DIR}/libexec"
CONF_DIR="${TARGET_DIR}/conf"
LOG_DIR="${TARGET_DIR}/logs"

# Service configuration
SERVICE_NAME="3proxy"
SERVICE_USER="proxy"
SERVICE_GROUP="proxy"

# 🔒 SECURITY: Using standard ports that are less likely to be scanned
HTTP_PORT="8080"
SOCKS_PORT="1080"

# Temporary directories
TMP_DIR="/tmp/3proxy-extract"
TMP_DEB="/tmp/3proxy-${VERSION}.deb"
DEB_URL="https://github.com/3proxy/3proxy/releases/download/${VERSION}/3proxy-${VERSION}.x86_64.deb"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------------------------------------------------------
# UTILITY FUNCTIONS
# ---------------------------------------------------------
print_usage() {
    echo "🔧 EasyProxy3 Service Manager & Installer"
    echo ""
    echo "Usage: $(basename "$0") [COMMAND]"
    echo ""
    echo "📦 Installation Commands:"
    echo "  install   📦 Install 3proxy service"
    echo "  remove    🗑️  Remove service completely"
    echo ""
    echo "🔧 Service Management:"
    echo "  start     ▶️  Start the 3proxy service"
    echo "  stop      ⏹️  Stop the 3proxy service" 
    echo "  restart   🔄 Restart the 3proxy service"
    echo "  status    📊 Show service status"
    echo "  enable    ✅ Enable service auto-start"
    echo "  disable   ❌ Disable service auto-start"
    echo ""
    echo "📋 Monitoring & Config:"
    echo "  logs      📋 Show recent logs"
    echo "  follow    📈 Follow logs in real-time"
    echo "  config    ⚙️  Edit configuration file"
    echo "  test      🧪 Test configuration syntax"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ Error: This operation requires root privileges${NC}"
        exit 1
    fi
}

service_exists() {
    systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service" 2>/dev/null
}

service_installed() {
    [[ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]] && [[ -f "${BIN_DIR}/3proxy" ]]
}

show_security_warning() {
    echo -e "${YELLOW}"
    echo "⚠️  SECURITY WARNING ⚠️"
    echo "========================"
    echo -e "${RED}🚨 DEFAULT CREDENTIALS DETECTED 🚨${NC}"
    echo ""
    echo "The service is using default credentials:"
    echo "  Username: ${USERNAME}"
    echo "  Password: ${PASSWORD}"
    echo ""
    echo -e "${YELLOW}🔒 IMMEDIATELY change these credentials by running:${NC}"
    echo -e "${GREEN}   sudo $(basename "$0") config${NC}"
    echo ""
    echo -e "${YELLOW}Edit the 'users' line and restart the service.${NC}"
    echo -e "${NC}"
}

# ---------------------------------------------------------
# INSTALLATION FUNCTIONS
# ---------------------------------------------------------
install_service() {
    check_root
    
    if service_installed; then
        echo -e "${YELLOW}⚠️  Service already installed. Use 'restart' to apply changes or 'remove' first.${NC}"
        return 0
    fi

    echo "🔍 [1/8] Performing system checks..."
    
    if ! command -v systemctl &> /dev/null; then
        echo -e "${RED}❌ Error: systemd not found. This script requires systemd.${NC}"
        exit 1
    fi

    echo "👤 [2/8] Creating service user and group..."
    
    if ! getent group "${SERVICE_GROUP}" > /dev/null 2>&1; then
        groupadd --system "${SERVICE_GROUP}"
        echo "    ✅ Created group: ${SERVICE_GROUP}"
    fi

    if ! getent passwd "${SERVICE_USER}" > /dev/null 2>&1; then
        useradd --system --gid "${SERVICE_GROUP}" \
                --home-dir "${TARGET_DIR}" \
                --shell /usr/sbin/nologin \
                --comment "3proxy service user" \
                "${SERVICE_USER}"
        echo "    ✅ Created user: ${SERVICE_USER}"
    fi

    echo "📁 [3/8] Creating directory structure..."
    mkdir -p "${BIN_DIR}" "${LIBEXEC_DIR}" "${CONF_DIR}" "${LOG_DIR}"

    # Set proper ownership and permissions
    chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${TARGET_DIR}"
    chmod 755 "${TARGET_DIR}" "${BIN_DIR}" "${LIBEXEC_DIR}" "${CONF_DIR}"
    chmod 750 "${LOG_DIR}"

    echo "    ✅ Directory structure created with proper permissions"

    echo "📦 [4/8] Downloading 3proxy ${VERSION}..."

    if command -v wget &>/dev/null; then
        wget -q -O "${TMP_DEB}" "${DEB_URL}"
    elif command -v curl &>/dev/null; then
        curl -sL -o "${TMP_DEB}" "${DEB_URL}"
    else
        echo -e "${RED}❌ Error: neither wget nor curl is installed${NC}"
        exit 1
    fi

    echo "📦 [5/8] Extracting 3proxy package..."
    rm -rf "${TMP_DIR}"
    mkdir -p "${TMP_DIR}"
    pushd "${TMP_DIR}" >/dev/null

    ar x "${TMP_DEB}"

    if [[ -f data.tar.xz ]]; then
        tar -xf data.tar.xz
    elif [[ -f data.tar.gz ]]; then
        tar -xf data.tar.gz
    else
        echo -e "${RED}❌ Error: data archive not found in .deb package${NC}"
        popd >/dev/null
        exit 1
    fi

    popd >/dev/null

    echo "🔧 [6/8] Installing 3proxy binaries..."

    if [[ -f "${TMP_DIR}/bin/3proxy" ]]; then
        cp "${TMP_DIR}/bin/3proxy" "${BIN_DIR}/3proxy"
        chmod 755 "${BIN_DIR}/3proxy"
        chown "${SERVICE_USER}:${SERVICE_GROUP}" "${BIN_DIR}/3proxy"
        echo "    ✅ Binary installed: ${BIN_DIR}/3proxy"
    else
        echo -e "${RED}❌ Error: 3proxy binary not found in package${NC}"
        exit 1
    fi

    # Install plugins if available
    if [[ -d "${TMP_DIR}/usr/local/3proxy/libexec" ]]; then
        cp "${TMP_DIR}/usr/local/3proxy/libexec/"* "${LIBEXEC_DIR}/" 2>/dev/null || true
        chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${LIBEXEC_DIR}"
        echo "    ✅ Plugins installed to ${LIBEXEC_DIR}/"
    fi

    echo "⚙️ [7/8] Creating configuration files..."

    cat > "${CONF_DIR}/3proxy.cfg" <<EOF
# ================================
# EasyProxy3 Configuration
# ================================
# 🔒 SECURITY: Change default credentials immediately!

daemon
pidfile ${TARGET_DIR}/3proxy.pid
log ${LOG_DIR}/3proxy.log D
logformat "- +_L%Y.%m.%d %H:%M:%S %N %p %E %U %C:%c %R:%r %T"

# 🚨 DEFAULT CREDENTIALS - CHANGE IMMEDIATELY!
# Edit the line below with your own username and password
users ${USERNAME}:CL:${PASSWORD}
auth strong
allow ${USERNAME}

# HTTP proxy (port ${HTTP_PORT})
proxy -p${HTTP_PORT}

flush

# SOCKS5 proxy (port ${SOCKS_PORT})  
socks -p${SOCKS_PORT}

# Security settings
maxconn 100
timeouts 30 60 30 10 3 60 180 1800 15 60
EOF

    chown "${SERVICE_USER}:${SERVICE_GROUP}" "${CONF_DIR}/3proxy.cfg"
    chmod 640 "${CONF_DIR}/3proxy.cfg"

    echo "🔄 [8/8] Creating systemd service..."

    cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=EasyProxy3 - lightweight proxy server
Documentation=https://github.com/AyoubJadouli/EasyProxy3---The-Simplest-Proxy-Server-Setup
After=network.target
Wants=network.target

[Service]
Type=forking
User=${SERVICE_USER}
Group=${SERVICE_GROUP}
PIDFile=${TARGET_DIR}/3proxy.pid
ExecStart=${BIN_DIR}/3proxy ${CONF_DIR}/3proxy.cfg
ExecReload=/bin/kill -HUP \$MAINPID
ExecStop=/bin/kill -TERM \$MAINPID
Restart=on-failure
RestartSec=5s

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${TARGET_DIR}
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    systemctl daemon-reload

    # Cleanup
    rm -rf "${TMP_DIR}" "${TMP_DEB}"

    echo ""
    echo -e "${GREEN}🎉 =============================================="
    echo "   EasyProxy3 installation completed!"
    echo "===============================================${NC}"
    echo ""
    echo "📋 Service Information:"
    echo "   • Service name: ${SERVICE_NAME}"
    echo "   • Service user: ${SERVICE_USER}"
    echo "   • HTTP proxy:   port ${HTTP_PORT}"
    echo "   • SOCKS5 proxy: port ${SOCKS_PORT}"
    echo ""
    
    show_security_warning
    
    echo "🔧 Quick Start:"
    echo "   $(basename "$0") enable    # Enable auto-start"
    echo "   $(basename "$0") start     # Start service"
    echo "   $(basename "$0") config    # 🚨 CHANGE CREDENTIALS!"
    echo "   $(basename "$0") status    # Check status"
    echo ""
}

remove_service() {
    check_root
    echo -e "${YELLOW}⚠️  This will completely remove the EasyProxy3 service and all its files${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
    
    echo "🗑️  Removing EasyProxy3 service..."
    
    # Stop and disable service
    systemctl stop "${SERVICE_NAME}" 2>/dev/null || true
    systemctl disable "${SERVICE_NAME}" 2>/dev/null || true
    
    # Remove service file
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    systemctl daemon-reload
    
    # Remove service user
    userdel "${SERVICE_USER}" 2>/dev/null || true
    groupdel "${SERVICE_GROUP}" 2>/dev/null || true
    
    # Remove files
    rm -rf "${TARGET_DIR}"
    
    echo -e "${GREEN}✅ EasyProxy3 service removed completely${NC}"
}

# ---------------------------------------------------------
# SERVICE MANAGEMENT FUNCTIONS
# ---------------------------------------------------------
cmd_start() {
    check_root
    if ! service_installed; then
        echo -e "${RED}❌ Service not installed. Run: $(basename "$0") install${NC}"
        exit 1
    fi
    
    echo "▶️  Starting ${SERVICE_NAME} service..."
    if systemctl start "${SERVICE_NAME}"; then
        echo -e "${GREEN}✅ Service started successfully${NC}"
        
        # Check if using default credentials
        if grep -q "${USERNAME}:CL:${PASSWORD}" "${CONF_DIR}/3proxy.cfg" 2>/dev/null; then
            echo ""
            show_security_warning
        fi
        
        systemctl status "${SERVICE_NAME}" --no-pager -l
    else
        echo -e "${RED}❌ Failed to start service${NC}"
        exit 1
    fi
}

cmd_stop() {
    check_root
    echo "⏹️  Stopping ${SERVICE_NAME} service..."
    if systemctl stop "${SERVICE_NAME}"; then
        echo -e "${GREEN}✅ Service stopped successfully${NC}"
    else
        echo -e "${RED}❌ Failed to stop service${NC}"
        exit 1
    fi
}

cmd_restart() {
    check_root
    echo "🔄 Restarting ${SERVICE_NAME} service..."
    if systemctl restart "${SERVICE_NAME}"; then
        echo -e "${GREEN}✅ Service restarted successfully${NC}"
        
        # Check if using default credentials
        if grep -q "${USERNAME}:CL:${PASSWORD}" "${CONF_DIR}/3proxy.cfg" 2>/dev/null; then
            echo ""
            show_security_warning
        fi
        
        systemctl status "${SERVICE_NAME}" --no-pager -l
    else
        echo -e "${RED}❌ Failed to restart service${NC}"
        exit 1
    fi
}

cmd_status() {
    if ! service_installed; then
        echo -e "${RED}❌ Service not installed${NC}"
        exit 1
    fi
    
    echo "📊 Service Status:"
    systemctl status "${SERVICE_NAME}" --no-pager -l
    
    echo ""
    echo "🔗 Network Status:"
    if command -v netstat &> /dev/null; then
        netstat -tlnp | grep -E ":${HTTP_PORT}|:${SOCKS_PORT}" || echo "No listening ports found"
    elif command -v ss &> /dev/null; then
        ss -tlnp | grep -E ":${HTTP_PORT}|:${SOCKS_PORT}" || echo "No listening ports found"
    fi
    
    # Security check
    if grep -q "${USERNAME}:CL:${PASSWORD}" "${CONF_DIR}/3proxy.cfg" 2>/dev/null; then
        echo ""
        echo -e "${RED}🚨 SECURITY ALERT: Using default credentials!${NC}"
        echo -e "${YELLOW}Run: sudo $(basename "$0") config to change them${NC}"
    fi
}

cmd_logs() {
    if ! service_installed; then
        echo -e "${RED}❌ Service not installed${NC}"
        exit 1
    fi
    
    echo "📋 Recent logs (systemd journal):"
    journalctl -u "${SERVICE_NAME}" --no-pager -n 50
    
    if [[ -f "${LOG_DIR}/3proxy.log" ]]; then
        echo ""
        echo "📋 Application logs:"
        tail -n 20 "${LOG_DIR}/3proxy.log"
    fi
}

cmd_follow() {
    if ! service_installed; then
        echo -e "${RED}❌ Service not installed${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📈 Following logs (Ctrl+C to exit)...${NC}"
    journalctl -u "${SERVICE_NAME}" -f
}

cmd_config() {
    check_root
    if [[ ! -f "${CONF_DIR}/3proxy.cfg" ]]; then
        echo -e "${RED}❌ Configuration file not found: ${CONF_DIR}/3proxy.cfg${NC}"
        exit 1
    fi
    
    echo "⚙️  Opening configuration file..."
    echo -e "${YELLOW}🔒 Remember to change the default username and password!${NC}"
    echo ""
    
    # Try different editors
    if command -v nano &> /dev/null; then
        nano "${CONF_DIR}/3proxy.cfg"
    elif command -v vim &> /dev/null; then
        vim "${CONF_DIR}/3proxy.cfg"
    elif command -v vi &> /dev/null; then
        vi "${CONF_DIR}/3proxy.cfg"
    else
        echo -e "${YELLOW}⚠️  No editor found. Configuration file location: ${CONF_DIR}/3proxy.cfg${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  Remember to restart the service after configuration changes:${NC}"
    echo -e "${GREEN}   sudo $(basename "$0") restart${NC}"
}

cmd_test() {
    if [[ ! -f "${CONF_DIR}/3proxy.cfg" ]]; then
        echo -e "${RED}❌ Configuration file not found${NC}"
        exit 1
    fi
    
    echo "🧪 Testing configuration..."
    if "${BIN_DIR}/3proxy" -t "${CONF_DIR}/3proxy.cfg"; then
        echo -e "${GREEN}✅ Configuration syntax is valid${NC}"
    else
        echo -e "${RED}❌ Configuration contains errors${NC}"
        exit 1
    fi
}

cmd_enable() {
    check_root
    if ! service_installed; then
        echo -e "${RED}❌ Service not installed${NC}"
        exit 1
    fi
    
    echo "✅ Enabling ${SERVICE_NAME} service for auto-start..."
    systemctl enable "${SERVICE_NAME}"
    echo -e "${GREEN}✅ Service enabled for auto-start on boot${NC}"
}

cmd_disable() {
    check_root
    echo "❌ Disabling ${SERVICE_NAME} service auto-start..."
    systemctl disable "${SERVICE_NAME}"
    echo -e "${GREEN}✅ Service disabled${NC}"
}

# ---------------------------------------------------------
# MAIN COMMAND DISPATCHER
# ---------------------------------------------------------
case "${1:-}" in
    install)
        install_service
        ;;
    remove)
        remove_service
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    status)
        cmd_status
        ;;
    logs)
        cmd_logs
        ;;
    follow)
        cmd_follow
        ;;
    config)
        cmd_config
        ;;
    test)
        cmd_test
        ;;
    enable)
        cmd_enable
        ;;
    disable)
        cmd_disable
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
