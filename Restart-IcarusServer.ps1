# Restart-IcarusServer.ps1
# Restarts the Icarus dedicated server with timed warnings
#
# IMPORTANT: AdminSay commands in Icarus require RCON access via in-game chat.
# This script provides TWO methods:
#
# METHOD 1 (Recommended): Use IcarusServerManager or RCON tool
# METHOD 2 (Fallback): Just restart the service (no warnings)

param(
    [switch]$NoWarnings,
    [string]$AdminPassword = "",
    [int]$RconPort = 0
)

$ServiceName = "IcarusServer"

# ANSI colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[36m"
$Reset = "`e[0m"

function Write-ColorOutput($Color, $Message) {
    Write-Host "$Color$Message$Reset"
}

function Send-AdminMessage {
    param([string]$Message)

    Write-ColorOutput $Blue "[$(Get-Date -Format 'HH:mm:ss')] Would send: $Message"

    # TODO: Implement RCON connection here
    # For now, this is a placeholder. You need to:
    # 1. Install an RCON client (e.g., via npm: npm install -g rcon-cli)
    # 2. Or use a PowerShell RCON module
    # 3. Or use the IcarusServerManager if available

    # Example using rcon-cli (if installed):
    # rcon -H localhost -P $RconPort -p $AdminPassword "AdminSay $Message"
}

function Restart-IcarusServerWithWarnings {
    Write-ColorOutput $Yellow "`n=== ICARUS SERVER RESTART SEQUENCE ===$Reset"
    Write-ColorOutput $Yellow "Starting at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

    # Check if service exists
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-ColorOutput $Red "ERROR: Service '$ServiceName' not found!"
        Write-ColorOutput $Yellow "Available services matching 'Icarus':"
        Get-Service | Where-Object {$_.Name -like "*Icarus*"} | Format-Table -AutoSize
        exit 1
    }

    if ($service.Status -ne 'Running') {
        Write-ColorOutput $Yellow "Service is not running. Current status: $($service.Status)"
        $continue = Read-Host "Start the service anyway? (y/n)"
        if ($continue -ne 'y') {
            exit 0
        }
    }

    # Warning sequence
    Write-ColorOutput $Yellow "[15 min warning]"
    Send-AdminMessage "⚠️ SERVER RESTART IN 15 MINUTES — scheduled maintenance"
    Start-Sleep -Seconds (10 * 60)  # 10 minutes

    Write-ColorOutput $Yellow "[5 min warning]"
    Send-AdminMessage "⚠️ SERVER RESTART IN 5 MINUTES — please return to safety"
    Start-Sleep -Seconds (4 * 60)   # 4 minutes

    Write-ColorOutput $Yellow "[1 min warning]"
    Send-AdminMessage "⚠️ SERVER RESTART IN 60 SECONDS — logout to avoid issues"
    Start-Sleep -Seconds 50         # 50 seconds

    Write-ColorOutput $Yellow "[10 sec warning]"
    Send-AdminMessage "🛑 SERVER RESTARTING NOW"
    Start-Sleep -Seconds 10

    # Restart the server
    Write-ColorOutput $Red "`nRestarting service: $ServiceName"
    try {
        Restart-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 5

        $service = Get-Service -Name $ServiceName
        if ($service.Status -eq 'Running') {
            Write-ColorOutput $Green "`n✓ Server restarted successfully!"
            Write-ColorOutput $Green "Status: $($service.Status)"
        } else {
            Write-ColorOutput $Red "⚠ Server may not have restarted properly."
            Write-ColorOutput $Yellow "Status: $($service.Status)"
        }
    }
    catch {
        Write-ColorOutput $Red "ERROR: Failed to restart service"
        Write-ColorOutput $Red $_.Exception.Message
        exit 1
    }

    Write-ColorOutput $Yellow "`nRestart sequence completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

function Restart-IcarusServerQuick {
    Write-ColorOutput $Yellow "Quick restart (no warnings)..."

    try {
        Restart-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 5

        $service = Get-Service -Name $ServiceName
        if ($service.Status -eq 'Running') {
            Write-ColorOutput $Green "✓ Server restarted successfully!"
        } else {
            Write-ColorOutput $Red "⚠ Service status: $($service.Status)"
        }
    }
    catch {
        Write-ColorOutput $Red "ERROR: $($_.Exception.Message)"
        exit 1
    }
}

# Main execution
if ($NoWarnings) {
    Restart-IcarusServerQuick
} else {
    Restart-IcarusServerWithWarnings
}
