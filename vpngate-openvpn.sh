#!/bin/bash

# VPN Gate OpenVPN Auto-Connect Script
VPNGATE_API="https://www.vpngate.net/api/iphone/"
CONFIG_DIR="/tmp/vpngate_configs"
CURRENT_CONFIG=""

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

# Get best server and download config
get_and_connect() {
    log "Fetching VPN Gate server list..."
    
    # Download server list
    wget -q -O /tmp/vpngate.csv "$VPNGATE_API"
    
    # Get best servers (high uptime, good speed)
    local servers=$(tail -n +2 /tmp/vpngate.csv | \
                   awk -F',' '$15 > 50000 && $5 > 1' | \
                   sort -t',' -k3 -nr | \
                   head -10)
    
    mkdir -p "$CONFIG_DIR"
    rm -f "$CONFIG_DIR"/*.ovpn
    
    # Try each server until one works
    while IFS= read -r server_line; do
        local country=$(echo "$server_line" | cut -d',' -f6)
        local config_data=$(echo "$server_line" | cut -d',' -f15)
        local host=$(echo "$server_line" | cut -d',' -f2)
        
        if [ -z "$config_data" ]; then continue; fi
        
        log "Trying server in $country ($host)..."
        
        # Decode base64 config
        local config_file="$CONFIG_DIR/vpngate_$country.ovpn"
        echo "$config_data" | base64 -d > "$config_file" 2>/dev/null
        
        if [ -s "$config_file" ]; then
            log "Connecting to $country server..."
            CURRENT_CONFIG="$config_file"
            
            # Connect with timeout
            timeout 30 sudo openvpn --config "$config_file" --daemon --writepid /var/run/openvpn-vpngate.pid
            
            # Check if connection succeeded
            sleep 5
            if pgrep -f "openvpn.*vpngate" > /dev/null; then
                log "Successfully connected to VPN Gate server in $country!"
                log "Your new IP:"
                curl -s ifconfig.me
                echo
                return 0
            fi
        fi
        
    done <<< "$servers"
    
    log "Failed to connect to any server"
    return 1
}

# Disconnect
disconnect() {
    log "Disconnecting from VPN Gate..."
    
    # Kill OpenVPN process
    if [ -f /var/run/openvpn-vpngate.pid ]; then
        sudo kill $(cat /var/run/openvpn-vpngate.pid) 2>/dev/null
        sudo rm -f /var/run/openvpn-vpngate.pid
    fi
    
    # Fallback: kill any vpngate openvpn process
    sudo pkill -f "openvpn.*vpngate"
    
    log "Disconnected"
}

# Check status
status() {
    if pgrep -f "openvpn.*vpngate" > /dev/null; then
        log "VPN Gate is connected"
        log "Current IP:"
        curl -s ifconfig.me
        echo
        return 0
    else
        log "VPN Gate is not connected"
        return 1
    fi
}

# Show help
show_help() {
    echo "VPN Gate OpenVPN Auto-Connect"
    echo "Usage: $0 {connect|disconnect|status}"
    echo ""
    echo "  connect     - Find and connect to best server"
    echo "  disconnect  - Disconnect from VPN"
    echo "  status      - Check connection status"
}

# Main argument handler
case "$1" in
    connect)
        disconnect 2>/dev/null
        get_and_connect
        ;;
    disconnect)
        disconnect
        ;;
    status)
        status
        ;;
    *)
        show_help
        ;;
esac
