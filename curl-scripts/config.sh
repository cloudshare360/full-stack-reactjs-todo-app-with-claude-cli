#!/bin/bash
# Dynamic Configuration for cURL Scripts
# This script detects the current environment and sets appropriate API endpoints

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to get the local hostname
get_hostname() {
    if command -v hostname >/dev/null 2>&1; then
        hostname
    else
        echo "localhost"
    fi
}

# Function to get the local IP address (first non-localhost IPv4)
get_local_ip() {
    if command -v ip >/dev/null 2>&1; then
        ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -1
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -E "inet ([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v "127.0.0.1" | awk '{ print $2 }' | head -1
    else
        echo "127.0.0.1"
    fi
}

# Environment detection
CURRENT_HOSTNAME=$(get_hostname)
LOCAL_IP=$(get_local_ip)

# Configuration variables with environment-based defaults
API_PROTOCOL=${API_PROTOCOL:-"http"}
API_HOST=${API_HOST:-"localhost"}
API_PORT=${API_PORT:-"5000"}

# Auto-detect API host if not explicitly set
if [ "$API_HOST" = "localhost" ] && [ "$LOCAL_IP" != "127.0.0.1" ]; then
    # If we have a real IP and no explicit host is set, offer options
    echo -e "${CYAN}🌐 Auto-detecting API server location...${NC}"
    echo -e "${BLUE}Current hostname: ${CURRENT_HOSTNAME}${NC}"
    echo -e "${BLUE}Local IP: ${LOCAL_IP}${NC}"

    # For now, keep localhost as default for simplicity
    # In production, you might want to use the local IP
    API_HOST="localhost"
fi

# Construct API base URL
API_BASE="${API_PROTOCOL}://${API_HOST}:${API_PORT}/api"

# Export for other scripts
export API_BASE
export API_PROTOCOL
export API_HOST
export API_PORT

# Function to print configuration
print_config() {
    echo -e "${PURPLE}📡 cURL Scripts Configuration${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
    echo -e "${BLUE}🌍 Hostname: ${CURRENT_HOSTNAME}${NC}"
    echo -e "${BLUE}🔗 Local IP: ${LOCAL_IP}${NC}"
    echo -e "${BLUE}🚀 API Base URL: ${API_BASE}${NC}"
    echo -e "${BLUE}📡 Protocol: ${API_PROTOCOL}${NC}"
    echo -e "${BLUE}🖥️  Host: ${API_HOST}${NC}"
    echo -e "${BLUE}🔌 Port: ${API_PORT}${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
}

# Function to test API connectivity
test_api_connectivity() {
    echo -e "${YELLOW}🔍 Testing API connectivity...${NC}"

    if curl -s -f "${API_BASE}/todos/stats" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ API is reachable at ${API_BASE}${NC}"
        return 0
    else
        echo -e "${RED}❌ API is not reachable at ${API_BASE}${NC}"

        # Try alternative hosts if localhost fails
        if [ "$API_HOST" = "localhost" ]; then
            echo -e "${YELLOW}💡 Trying alternative hosts...${NC}"

            # Try local IP
            if [ "$LOCAL_IP" != "127.0.0.1" ]; then
                ALT_API_BASE="${API_PROTOCOL}://${LOCAL_IP}:${API_PORT}/api"
                if curl -s -f "${ALT_API_BASE}/todos/stats" >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ API found at ${ALT_API_BASE}${NC}"
                    export API_BASE="$ALT_API_BASE"
                    export API_HOST="$LOCAL_IP"
                    return 0
                fi
            fi

            # Try hostname
            if [ "$CURRENT_HOSTNAME" != "localhost" ]; then
                ALT_API_BASE="${API_PROTOCOL}://${CURRENT_HOSTNAME}:${API_PORT}/api"
                if curl -s -f "${ALT_API_BASE}/todos/stats" >/dev/null 2>&1; then
                    echo -e "${GREEN}✅ API found at ${ALT_API_BASE}${NC}"
                    export API_BASE="$ALT_API_BASE"
                    export API_HOST="$CURRENT_HOSTNAME"
                    return 0
                fi
            fi
        fi

        echo -e "${RED}💥 API is not available on any tested host${NC}"
        echo -e "${YELLOW}📋 Make sure the Express API server is running:${NC}"
        echo -e "${BLUE}   cd express-js-rest-api && npm run dev${NC}"
        return 1
    fi
}

# Function to save current configuration
save_config() {
    cat > .curl-config << EOF
# Saved cURL Scripts Configuration
# Generated on: $(date)
API_PROTOCOL=${API_PROTOCOL}
API_HOST=${API_HOST}
API_PORT=${API_PORT}
API_BASE=${API_BASE}
CURRENT_HOSTNAME=${CURRENT_HOSTNAME}
LOCAL_IP=${LOCAL_IP}
EOF
}

# Function to load saved configuration
load_config() {
    if [ -f ".curl-config" ]; then
        echo -e "${CYAN}📂 Loading saved configuration...${NC}"
        source .curl-config
        export API_BASE API_PROTOCOL API_HOST API_PORT
    fi
}

# Main configuration logic
main() {
    # Load any saved configuration first
    load_config

    # Print current configuration
    print_config

    # Test connectivity
    if test_api_connectivity; then
        # Save working configuration
        save_config
        echo -e "${GREEN}💾 Configuration saved${NC}"
    fi
}

# If script is executed directly (not sourced), run main
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main
fi