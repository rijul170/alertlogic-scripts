# Alert Logic Agent Reinstall Script for AWS Windows Instances
# No registration key needed for AWS
# Reference: https://docs.alertlogic.com/prepare/alert-logic-agent-windows.htm

Write-Host "[INFO] Starting Alert Logic agent removal and reinstallation..."

# Step 1: Stop service
Write-Host "[INFO] Stopping Alert Logic service..."
Stop-Service -Name "al_agent" -ErrorAction SilentlyContinue

# Step 2: Uninstall the agent
Write-Host "[INFO] Uninstalling Alert Logic agent..."
$agent = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Alert Logic" }
if ($agent) {
    $agent.Uninstall()
}

# Step 3: Clean up leftover files
Remove-Item -Recurse -Force "C:\Program Files\AlertLogic" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "C:\ProgramData\AlertLogic" -ErrorAction SilentlyContinue

# Step 4: Download and install latest agent
Write-Host "[INFO] Downloading and installing new Alert Logic agent..."
$installerUrl = "https://scc.alertlogic.net/software/al_agent-latest.msi"
$installerPath = "$env:TEMP\al_agent-latest.msi"

Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

# Step 5: Start the service
Start-Service -Name "al_agent"

Write-Host "[SUCCESS] Alert Logic agent reinstalled successfully."
