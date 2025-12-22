# Icarus Server Restart Script

PowerShell script to restart your Icarus dedicated server with timed player warnings.

## Quick Start

### Basic Usage (No Warnings)

```powershell
.\Restart-IcarusServer.ps1 -NoWarnings
```

### With Warnings (15 min countdown)

```powershell
.\Restart-IcarusServer.ps1
```

## Problem: Admin Messages

Icarus uses **RCON commands via in-game chat** for admin functions. The `AdminSay` command requires you to be logged into the game and type commands in chat (e.g., `/AdminSay Hello players`).

This makes automated admin messages challenging. Your original AutoHotkey approach tried to solve this but has issues:

- ❌ AutoHotkey not installed on Windows 11
- ❌ Requires game window to be active/focused
- ❌ Fragile and timing-dependent

## Solutions for Admin Messages

### Option 1: Use RCON Client (Recommended)

Install a proper RCON client that can connect to the server:

#### Using rcon-cli (Node.js)

```powershell
# Install Node.js first, then:
npm install -g rcon-cli

# Send message:
rcon -H localhost -P 27015 -p YourAdminPassword "AdminSay Server restarting soon"
```

Then update the script to use it:

```powershell
# In Send-AdminMessage function:
rcon -H localhost -P $RconPort -p $AdminPassword "AdminSay $Message"
```

#### Using mcrcon (C-based)

Download from: https://github.com/Tiiffi/mcrcon

```powershell
mcrcon.exe -H localhost -P 27015 -p YourAdminPassword "AdminSay Server restarting"
```

### Option 2: IcarusServerManager Tool

Check if there's a community-made server manager tool that provides RCON functionality:

- https://github.com/search?q=icarus+server+manager
- Many game server managers provide RCON interfaces

### Option 3: Manual Operation

If automated messages aren't critical:

```powershell
# Just restart without warnings
.\Restart-IcarusServer.ps1 -NoWarnings
```

Or manually send messages in-game before running the script:

1. Join the server
2. Type: `/AdminLogin YourPassword`
3. Type: `/AdminSay Server restarting in 15 minutes`
4. Run: `.\Restart-IcarusServer.ps1 -NoWarnings`

### Option 4: Keep AutoHotkey (Install It)

Install AutoHotkey on your Windows 11 box:

1. Download from: https://www.autohotkey.com/
2. Install to: `C:\Program Files\AutoHotkey\`
3. Use your original `Restart-Icarus.ps1` script

**Note**: This still requires the game window to be open and active.

## Configuration

Edit the script variables at the top if needed:

```powershell
$ServiceName = "IcarusServer"  # Your Windows service name
$RconPort = 27015              # Your RCON port (check ServerSettings.ini)
$AdminPassword = "your_pass"   # Your admin password
```

## Scheduled Restarts

To schedule automatic restarts, use Windows Task Scheduler.

**⚠️ IMPORTANT**: You must run PowerShell as Administrator to create scheduled tasks.

**How to open PowerShell as Admin:**

1. Press `Win + X` on your keyboard
2. Click "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Or: Search for "PowerShell" in Start Menu → Right-click → "Run as administrator"

### Option A: Restart Every 5 Hours (Recommended)

```powershell
# Run as Administrator
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Users\newdark\icarus\Restart-IcarusServer.ps1"

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 5)

Register-ScheduledTask -Action $action -Trigger $trigger `
    -TaskName "Icarus Server Restart Every 5 Hours" `
    -Description "Restarts Icarus server every 5 hours with player warnings" `
    -User "SYSTEM" -RunLevel Highest
```

### Option B: Restart Daily at Specific Time

```powershell
# Run at 3 AM daily with warnings
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Users\newdark\icarus\Restart-IcarusServer.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 3am

Register-ScheduledTask -Action $action -Trigger $trigger `
    -TaskName "Icarus Server Daily Restart" `
    -Description "Daily Icarus server restart with warnings" `
    -User "SYSTEM" -RunLevel Highest
```

### Manage Scheduled Tasks

```powershell
# View the task
Get-ScheduledTask -TaskName "Icarus Server*"

# Remove the task
Unregister-ScheduledTask -TaskName "Icarus Server Restart Every 5 Hours" -Confirm:$false

# Disable the task temporarily
Disable-ScheduledTask -TaskName "Icarus Server Restart Every 5 Hours"

# Enable it again
Enable-ScheduledTask -TaskName "Icarus Server Restart Every 5 Hours"
```

## Files

- `Restart-IcarusServer.ps1` - Main restart script with warnings
- `AdminSay.ahk` - Original AutoHotkey script (requires AHK installed)
- `Restart-Icarus.ps1` - Original script (requires AHK)

## Server Setup Reference

- Official docs: https://github.com/RocketWerkz/IcarusDedicatedServer/wiki
- RCON commands: https://github.com/RocketWerkz/IcarusDedicatedServer/wiki/Console---RCON-Commands

## Troubleshooting

### Service not found

```powershell
# List all services with "Icarus" in the name
Get-Service | Where-Object {$_.Name -like "*Icarus*"}

# Update $ServiceName in the script to match
```

### Permission denied

**Method 1: Open PowerShell as Administrator**

1. Press `Win + X` on your keyboard
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
3. Click "Yes" on the UAC prompt

**Method 2: From Start Menu**

1. Click Start and type "PowerShell"
2. Right-click "Windows PowerShell"
3. Select "Run as administrator"

**Method 3: From File Explorer**

1. Navigate to your script folder
2. Hold `Shift` + Right-click in empty space
3. Select "Open PowerShell window here as administrator"

**Method 4: From existing PowerShell window**

```powershell
Start-Process PowerShell -Verb RunAs
```

### Script execution disabled

```powershell
# Allow script execution (one-time)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
