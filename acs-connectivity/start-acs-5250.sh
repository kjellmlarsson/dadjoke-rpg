#!/bin/bash

#==============================================================================
# IBM i Access Client Solutions 5250 Launcher
#==============================================================================
# Purpose: Launches IBM i Access Client Solutions 5250 emulator
#
# Usage:
#   ./start-acs-5250.sh
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ACS_JAR="/usr/local/ibmiaccess/acsbundle.jar"
readonly ACS_SYSTEM="localhost"
readonly ACS_PORT="50000"
readonly LOG_FILE="${SCRIPT_DIR}/acs-launch.log"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Print colored output
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $*" | tee -a "${LOG_FILE}"
}

#------------------------------------------------------------------------------
# Main Execution
#------------------------------------------------------------------------------

log_info "=========================================="
log_info "Launching IBM i Access Client Solutions"
log_info "=========================================="
log_info "Starting 5250 emulator on ${ACS_SYSTEM}:${ACS_PORT}..."
log_info ""

# Launch 5250 emulator (user will login manually in the GUI)
java -jar "${ACS_JAR}" \
    /PLUGIN=5250 \
    /SYSTEM="${ACS_SYSTEM}" \
    /PORT="${ACS_PORT}" \
    &

log_info "5250 emulator launched (PID: $!)"
log_info "Login credentials will be requested in the ACS window"
log_info "=========================================="
log_info ""

# Made with Bob