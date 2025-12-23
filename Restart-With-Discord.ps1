# Restart-With-Discord.ps1
# Restarts Icarus server with Discord notifications

param(
    [string]$WebhookUrl = ""  # Your Discord webhook URL
)

$ServiceName = "IcarusServer"

# ANSI colors
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Reset = "`e[0m"

function Write-ColorOutput($Color, $Message) {
    Write-Host "$Color$Message$Reset"
}

function Send-DiscordMessage {
    param([string]$Message)

    if ([string]::IsNullOrEmpty($WebhookUrl)) {
        Write-ColorOutput $Yellow "No Discord webhook configured. Skipping notification."
        return
    }

    $payload = @{
        content = $Message
        username = "Icarus Server"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType 'application/json' | Out-Null
        Write-ColorOutput $Green "✓ Discord message sent"
    }
    catch {
        Write-ColorOutput $Red "Failed to send Discord message: $($_.Exception.Message)"
    }
}

function Restart-IcarusWithNotifications {
    Write-ColorOutput $Yellow "`n=== ICARUS SERVER RESTART SEQUENCE ==="
    Write-ColorOutput $Yellow "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

    # Check if service exists
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-ColorOutput $Red "ERROR: Service '$ServiceName' not found!"
        exit 1
    }

    # 15 minute warning
    Write-ColorOutput $Yellow "[15 min] Sending warning..."
    Send-DiscordMessage "⚠️ **SERVER RESTART IN 15 MINUTES**`nScheduled maintenance. Please wrap up your activities and return to safety."
    Start-Sleep -Seconds (10 * 60)

    # 5 minute warning
    Write-ColorOutput $Yellow "[5 min] Sending warning..."
    Send-DiscordMessage "⚠️ **SERVER RESTART IN 5 MINUTES**`nPlease return to a safe location and prepare to logout."
    Start-Sleep -Seconds (4 * 60)

    # 1 minute warning
    Write-ColorOutput $Yellow "[1 min] Sending warning..."
    Send-DiscordMessage "⚠️ **SERVER RESTART IN 60 SECONDS**`nLogout now to avoid losing progress!"
    Start-Sleep -Seconds 50

    # Final warning
    Write-ColorOutput $Yellow "[NOW] Sending final notice..."
    Send-DiscordMessage "🛑 **SERVER RESTARTING NOW**"
    Start-Sleep -Seconds 10

    # Restart
    Write-ColorOutput $Red "`nRestarting service: $ServiceName"
    try {
        Restart-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 5

        $service = Get-Service -Name $ServiceName
        if ($service.Status -eq 'Running') {
            Write-ColorOutput $Green "`n✓ Server restarted successfully!"
            Send-DiscordMessage "✅ **Server is back online!** Happy surviving! 🌲"
        }
    }
    catch {
        Write-ColorOutput $Red "ERROR: $($_.Exception.Message)"
        Send-DiscordMessage "❌ Server restart failed - checking now!"
        exit 1
    }

    Write-ColorOutput $Yellow "`nCompleted at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Main execution
if ([string]::IsNullOrEmpty($WebhookUrl)) {
    Write-ColorOutput $Red "`nERROR: No Discord webhook URL provided!"
    Write-ColorOutput $Yellow "Usage: .\Restart-With-Discord.ps1 -WebhookUrl 'https://discord.com/api/webhooks/...'"
    Write-ColorOutput $Yellow "`nTo get a webhook URL:"
    Write-ColorOutput $Yellow "1. Go to your Discord server"
    Write-ColorOutput $Yellow "2. Edit a channel > Integrations > Webhooks"
    Write-ColorOutput $Yellow "3. Create webhook, copy URL"
    Write-ColorOutput $Yellow "4. Save it in this script or pass as parameter`n"
    exit 1
}

Restart-IcarusWithNotifications
