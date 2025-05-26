#!/bin/bash

# Alert Logic Agent Reinstall Script for AWS Linux Instances
# No registration key needed for AWS
# Reference: https://docs.alertlogic.com/prepare/alert-logic-agent-linux.htm

set -e
LOGFILE="/var/log/alertlogic_reinstall.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

echo "[INFO] Starting Alert Logic agent removal and reinstallation..."

# Step 1: Stop and remove the agent
echo "[INFO] Stopping Alert Logic agent..."
sudo systemctl stop al-agent || true
sudo service al-agent stop || true

echo "[INFO] Uninstalling existing Alert Logic agent..."
sudo yum remove -y al-agent || sudo apt-get remove -y al-agent || true
sudo rm -rf /var/alertlogic /var/log/alertlogic /etc/alertlogic || true

# Step 2: Download and install the agent
echo "[INFO] Downloading and installing new Alert Logic agent..."
curl -sSL https://scc.alertlogic.net/software/al-agent-Linux-latest.sh -o al-agent-install.sh
chmod +x al-agent-install.sh
sudo ./al-agent-install.sh -i --install-only

# Step 3: Enable and start the agent
sudo systemctl enable al-agent || sudo chkconfig al-agent on
sudo systemctl start al-agent || sudo service al-agent start

echo "[SUCCESS] Alert Logic agent reinstalled successfully."
