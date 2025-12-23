# Restart-IcarusServer.ps1
# Restarts the Icarus dedicated server
#
# IMPORTANT: Icarus does NOT have network RCON support!
# AdminSay commands ONLY work from in-game chat when a player is logged in.
# Without a game client running on the server, automated warnings are not possible.
#
# This script simply restarts the Windows service.

param(
    [int]$WaitMinutes = 0
)

$ServiceName = "IcarusServer"

# ANSI colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
# ANSI colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Reset = "`e[0m"

function Write-ColorOutput($Color, $Message) {
    Write-Host "$Color$Message$Reset"
}

function Restart-IcarusServer {
    Write-ColorOutput $Yellow "`n=== ICARUS SERVER RESTART ==="
    Write-ColorOutput $Yellow "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

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

    # Optional wait period
    if ($WaitMinutes -gt 0) {
        Write-ColorOutput $Yellow "Waiting $WaitMinutes minutes before restart..."
        Write-ColorOutput $Yellow "TIP: Manually send in-game warnings to players during this time"
        Start-Sleep -Seconds ($WaitMinutes * 60)
    }

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

    Write-ColorOutput $Yellow "`nCompleted at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Main execution
Restart-IcarusServer
