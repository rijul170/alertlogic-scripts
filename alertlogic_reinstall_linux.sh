#!/bin/bash

# Alert Logic Agent Reinstall Script for AWS-based Linux servers
# No registration key needed for AWS
# Reference: https://docs.alertlogic.com/prepare/alert-logic-agent-linux.htm

set -e
LOGFILE="/var/log/alertlogic_reinstall.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

echo "[INFO] Starting Alert Logic agent uninstall/reinstall process..."

# Step 1: Stop the agent service
echo "[INFO] Stopping Alert Logic service if running..."
sudo systemctl stop al-agent || sudo service al-agent stop || true

# Step 2: Uninstall the agent
echo "[INFO] Uninstalling existing Alert Logic agent..."
sudo yum remove -y al-agent || sudo apt-get remove -y al-agent || true

# Step 3: Clean up leftover files
echo "[INFO] Cleaning up agent directories..."
sudo rm -rf /var/alertlogic /var/log/alertlogic /etc/alertlogic

# Step 4: Download new agent install script
INSTALLER_URL="https://scc.alertlogic.net/software/al-agent-Linux-x86_64-latest.sh"
INSTALLER_FILE="al-agent-install.sh"

echo "[INFO] Downloading the latest Alert Logic installer..."
curl -sSL $INSTALLER_URL -o $INSTALLER_FILE

# Step 5: Check if the downloaded file is valid (not an HTML error page)
if grep -q '<!DOCTYPE html>' $INSTALLER_FILE; then
    echo "[ERROR] Failed to download the Alert Logic installer. The URL may be invalid or unreachable."
    rm -f $INSTALLER_FILE
    exit 1
fi

# Step 6: Make installer executable and install
chmod +x $INSTALLER_FILE
echo "[INFO] Running the Alert Logic installer..."
sudo ./$INSTALLER_FILE -i --install-only

# Step 7: Enable and start the agent
echo "[INFO] Enabling and starting Alert Logic service..."
sudo systemctl enable al-agent || sudo chkconfig al-agent on
sudo systemctl start al-agent || sudo service al-agent start

echo "[SUCCESS] Alert Logic agent reinstalled and started successfully."
