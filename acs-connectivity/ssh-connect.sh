#!/bin/bash

#==============================================================================
# SSH Tunnel Script for IBM i System Access
#==============================================================================
# Purpose: Establishes SSH tunnels for IBM i Access Client Solutions (ACS)
# and related services to remote IBM i system
#
# Port Mappings:
#   50000 - Telnet (port 23)
#   2001  - IBM i Access Server (SSL)
#   2002  - IBM i Access Server (non-SSL)
#   449   - IBM i Access Server (AS-SVRMAP)
#   8470-8476 - IBM i Access Client Solutions services
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SSH_KEY="../private_key.pem"
readonly REMOTE_USER="cecuser"
readonly REMOTE_HOST="158.176.147.237"
readonly LOG_FILE="${SCRIPT_DIR}/ssh-tunnel.log"

# Port forwarding configuration (local:remote)
readonly PORT_FORWARDS=(
    "50000:localhost:23"    # Telnet
    "2001:localhost:2001"   # IBM i Access (SSL)
    "2002:localhost:2002"   # IBM i Access (non-SSL)
    "449:localhost:449"     # AS-SVRMAP
    "8470:localhost:8470"   # ACS Service 1
    "8471:localhost:8471"   # ACS Service 2
    "8472:localhost:8472"   # ACS Service 3
    "8473:localhost:8473"   # ACS Service 4
    "8474:localhost:8474"   # ACS Service 5
    "8475:localhost:8475"   # ACS Service 6
    "8476:localhost:8476"   # ACS Service 7
    "8076:localhost:8076"   # ACS Service 7

)

# SSH connection options (base options, -N flag added conditionally)
readonly SSH_OPTS_BASE=(
    "-4"                                    # Force IPv4
    "-o ExitOnForwardFailure=yes"          # Exit if port forwarding fails
    "-o ServerAliveInterval=15"            # Send keepalive every 15s
    "-o ServerAliveCountMax=3"             # Max 3 missed keepalives
    "-o ConnectTimeout=10"                 # Connection timeout
    "-o StrictHostKeyChecking=accept-new"  # Accept new host keys
    "-o LogLevel=INFO"                     # Logging level
)

# Connection mode (set by user selection)
CONNECTION_MODE=""

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Print colored output
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $*" | tee -a "${LOG_FILE}"
}

# Build SSH command with port forwards
build_ssh_command() {
    local -a cmd=("sudo" "ssh")
    
    # Add base SSH options
    cmd+=("${SSH_OPTS_BASE[@]}")
    
    # Add -N flag for tunnel-only mode
    if [[ "${CONNECTION_MODE}" == "tunnel" ]]; then
        cmd+=("-N")
    fi
    
    # Add port forwards
    for forward in "${PORT_FORWARDS[@]}"; do
        cmd+=("-L" "${forward}")
    done
    
    # Add key and destination
    cmd+=("-i" "${SSH_KEY}" "${REMOTE_USER}@${REMOTE_HOST}")
    
    # Return the command array via a global variable
    SSH_COMMAND=("${cmd[@]}")
}

# Prompt user to select connection mode
select_connection_mode() {
    echo ""
    echo "=========================================="
    echo "SSH Connection Mode Selection"
    echo "=========================================="
    echo ""
    echo "1) Tunnel only (background, no terminal)"
    echo "   - Establishes port forwards in background"
    echo "   - Returns to your local shell"
    echo "   - Use for running ACS or other services"
    echo ""
    echo "2) Interactive terminal with tunnel"
    echo "   - Opens remote shell on IBM i system"
    echo "   - Port forwards active during session"
    echo "   - Exit shell to close tunnel"
    echo ""
    
    while true; do
        read -p "Select mode [1-2]: " choice
        case $choice in
            1)
                CONNECTION_MODE="tunnel"
                log_info "Selected: Tunnel only mode"
                break
                ;;
            2)
                CONNECTION_MODE="interactive"
                log_info "Selected: Interactive terminal mode"
                break
                ;;
            *)
                echo "Invalid selection. Please enter 1 or 2."
                ;;
        esac
    done
    echo ""
}

# Cleanup function for graceful shutdown
cleanup() {
    local exit_code=$?
    log_info "Shutting down SSH tunnel..."
    
    # Kill any remaining SSH processes for this connection
    pkill -f "ssh.*${REMOTE_HOST}" 2>/dev/null || true
    
    exit "${exit_code}"
}

# Display connection information
show_connection_info() {
    log_info "=========================================="
    log_info "SSH Tunnel Configuration"
    log_info "=========================================="
    log_info "Remote Host: ${REMOTE_USER}@${REMOTE_HOST}"
    log_info "SSH Key: ${SSH_KEY}"
    log_info ""
    log_info "Port Forwards:"
    for forward in "${PORT_FORWARDS[@]}"; do
        log_info "  ${forward}"
    done
    log_info "=========================================="
    log_info ""
}

#------------------------------------------------------------------------------
# Main Execution
#------------------------------------------------------------------------------

main() {
    log_info "Starting SSH tunnel setup at $(date)"
    
    # Display configuration
    show_connection_info
    
    # Prompt user to select connection mode
    select_connection_mode
    
    # Set up cleanup trap
    trap cleanup EXIT INT TERM
    
    # Build and execute SSH command
    log_info "Establishing SSH connection..."
    log_info ""
    
    # First, authenticate sudo (this will prompt for password and wait)
    sudo -v
    
    # Build the SSH command
    build_ssh_command
    
    if [[ "${CONNECTION_MODE}" == "tunnel" ]]; then
        # Tunnel-only mode: run in background
        log_info "Starting SSH tunnel in background..."
        
        # Execute SSH command in background (sudo is already authenticated)
        "${SSH_COMMAND[@]}" &
        local ssh_pid=$!
        
        # Give a moment for the tunnel to fully establish
        sleep 3
        
        # Verify the SSH process is still running
        if ! kill -0 ${ssh_pid} 2>/dev/null; then
            log_info "ERROR: SSH tunnel failed to establish"
            exit 1
        fi
        
        log_info "SSH tunnel established (PID: ${ssh_pid})"
        log_info ""
        log_info "To launch ACS 5250 emulator, run:"
        log_info "  ./start-acs-5250.sh"
        log_info ""
        
        # Keep script running and monitor SSH tunnel
        log_info "SSH tunnel is running and ready"
        log_info "Press Ctrl+C to disconnect and close the tunnel"
        log_info ""
        
        # Wait for SSH process
        wait ${ssh_pid}
        
        # This line is reached only if SSH exits
        log_info "SSH connection terminated unexpectedly"
        exit 1
        
    else
        # Interactive mode: run in foreground
        log_info "Opening interactive terminal with port forwarding..."
        log_info "Port forwards will remain active during your session"
        log_info "Type 'exit' or press Ctrl+D to close connection and tunnel"
        log_info ""
        
        # Execute SSH command in foreground (interactive)
        "${SSH_COMMAND[@]}"
        
        # This line is reached when user exits the shell
        log_info "SSH session closed"
    fi
}

# Run main function
main "$@"