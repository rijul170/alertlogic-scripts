#!/bin/bash

# Script to uninstall and reinstall Alert Logic agent on AWS-based Linux/Unix servers
# Reference: https://docs.alertlogic.com/prepare/alert-logic-agent-linux.htm
# Reference: https://docs.alertlogic.com/prepare/alert-logic-agent-linux-uninstall.htm
# Usage: sudo ./alertlogic_reinstall.sh

set -e
LOGFILE="/var/log/alertlogic_reinstall.log"

# Trap for any unexpected errors
trap 'echo "[ERROR] Script failed. Check $LOGFILE for details." | tee -a $LOGFILE' ERR

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must be run as root or with sudo." | tee -a $LOGFILE
    exit 1
fi

echo "[INFO] Starting Alert Logic agent uninstall/reinstall process..." | tee -a $LOGFILE

# Function to stop and remove the agent cleanly
uninstall_agent() {
    echo "[INFO] Checking for existing Alert Logic agent..." | tee -a $LOGFILE
    if systemctl is-active --quiet al-agent; then
        echo "[INFO] Stopping Alert Logic agent service..." | tee -a $LOGFILE
        systemctl stop al-agent
    fi

    echo "[INFO] Disabling Alert Logic agent service..." | tee -a $LOGFILE
    systemctl disable al-agent || true

    echo "[INFO] Removing Alert Logic packages..." | tee -a $LOGFILE
    if command -v yum > /dev/null 2>&1; then
        yum remove -y al-agent
    elif command -v apt-get > /dev/null 2>&1; then
        apt-get purge -y al-agent
        apt-get autoremove -y
    fi

    echo "[INFO] Deleting configuration and logs..." | tee -a $LOGFILE
    rm -rf /etc/alertlogic /var/log/alertlogic /var/db/alertlogic /var/lib/alertlogic
    echo "[INFO] Agent uninstalled successfully." | tee -a $LOGFILE
}

# Function to install the agent (no activation key needed for AWS)
reinstall_agent() {
    echo "[INFO] Downloading AWS-specific Alert Logic agent install script..." | tee -a $LOGFILE
    curl -fsSL https://scc.alertlogic.net/software/agent-updates/installscripts/alinux_installer.sh -o alinux_installer.sh

    if [ ! -f alinux_installer.sh ]; then
        echo "[ERROR] Failed to download the installer script." | tee -a $LOGFILE
        exit 1
    fi

    chmod +x alinux_installer.sh

    echo "[INFO] Running the installation script..." | tee -a $LOGFILE
    ./alinux_installer.sh --aws

    echo "[INFO] Verifying agent status..." | tee -a $LOGFILE
    systemctl status al-agent
    echo "[INFO] Alert Logic agent installed and running successfully." | tee -a $LOGFILE
}

# Main flow
uninstall_agent
reinstall_agent

echo "[INFO] Alert Logic agent reinstall process completed successfully." | tee -a $LOGFILE
