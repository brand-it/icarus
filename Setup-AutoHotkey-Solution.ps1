# Setup-AutoHotkey-Solution.ps1
# Installs and configures AutoHotkey for in-game admin messages

$AhkDownloadUrl = "https://www.autohotkey.com/download/ahk-install.exe"
$AhkInstaller = "$env:TEMP\ahk-install.exe"
$AhkPath = "C:\Program Files\AutoHotkey\AutoHotkey.exe"

Write-Host "`n=== AutoHotkey Setup for Icarus Admin Messages ===`n" -ForegroundColor Cyan

# Check if already installed
if (Test-Path $AhkPath) {
    Write-Host "✓ AutoHotkey is already installed at: $AhkPath" -ForegroundColor Green
} else {
    Write-Host "Downloading AutoHotkey..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $AhkDownloadUrl -OutFile $AhkInstaller
        Write-Host "Installing AutoHotkey (you may see UAC prompt)..." -ForegroundColor Yellow
        Start-Process -FilePath $AhkInstaller -ArgumentList "/S" -Wait

        if (Test-Path $AhkPath) {
            Write-Host "✓ AutoHotkey installed successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Installation may have failed. Please install manually from: https://www.autohotkey.com/" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "✗ Download failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please download manually from: https://www.autohotkey.com/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "`n=== IMPORTANT: Game Client Setup ===`n" -ForegroundColor Cyan
Write-Host "For this to work, you MUST:" -ForegroundColor Yellow
Write-Host "1. Keep Icarus game client running on the server" -ForegroundColor White
Write-Host "2. Login to your server as admin" -ForegroundColor White
Write-Host "3. Leave the game running (can minimize to taskbar)" -ForegroundColor White
Write-Host "4. The script will activate the window and send chat commands`n" -ForegroundColor White

Write-Host "This is a WORKAROUND since Icarus has no network RCON support." -ForegroundColor Yellow
Write-Host "It's not ideal, but it DOES work for sending AdminSay messages.`n" -ForegroundColor Yellow

Write-Host "✓ Setup complete! You can now use:" -ForegroundColor Green
Write-Host "  .\Restart-Icarus.ps1`n" -ForegroundColor White
