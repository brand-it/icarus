# Icarus Server Restart Script

PowerShell script to restart your Icarus dedicated server.

## ⚡ Before You Start: Enable PowerShell Scripts

Windows 11 blocks running PowerShell scripts by default. Run this **ONCE** as Administrator:

```powershell
# Open PowerShell as Administrator (Win + X, then select "Terminal (Admin)")
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

When prompted, type **Y** and press Enter.

**What this does:** Allows running locally-created scripts while still blocking downloaded scripts (unless you unblock them).

### Unblock Downloaded Scripts

If you downloaded these scripts from GitHub, Windows may block them. Unblock all scripts:

```powershell
# In the icarus folder, run:
Get-ChildItem -Path . -Filter *.ps1 | Unblock-File
```

**Or unblock via GUI:**

1. Right-click each `.ps1` file in File Explorer
2. Click **Properties**
3. Check the **Unblock** box at the bottom
4. Click **OK**

## 🚀 First Time Setup: Install as Windows Service

If you're just running IcarusServer.exe by clicking it, you need to set it up as a Windows service first:

```powershell
# Run PowerShell as Administrator from C:\Users\newdark\icarus\
.\Install-As-Service.ps1

# Default path is C:\Users\newdark\icarus
# If your IcarusServer.exe is elsewhere, specify with:
.\Install-As-Service.ps1 -ServerPath "C:\YourPath"
```

**What this does:**

- Downloads NSSM (service wrapper tool)
- Creates a Windows service called "IcarusServer"
- Sets it to start automatically with Windows
- Configures auto-restart on crashes

**After this, your server will:**

- Start automatically when Windows boots
- Run in the background (no window)
- Be manageable with the restart scripts

## Quick Start

### Immediate Restart

```powershell
.\Restart-IcarusServer.ps1
```

### Restart with Delay (gives time for manual warnings)

```powershell
# Wait 15 minutes before restarting
.\Restart-IcarusServer.ps1 -WaitMinutes 15
```

## 💬 Player Notification Solutions

**The Problem**: Icarus does NOT support network RCON. `AdminSay` only works from in-game chat when logged in.

### Solution 1: Discord Notifications (RECOMMENDED) ⭐

Post restart warnings to Discord where your players actually see them:

```powershell
.\Restart-With-Discord.ps1 -WebhookUrl "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
```

**Setup Discord Webhook:**

1. Go to your Discord server
2. Server Settings > Integrations > Webhooks > New Webhook
3. Choose a channel (e.g., #server-announcements)
4. Copy the webhook URL
5. Use it in the script above

**Benefits:**

- ✅ Players get notifications on their phones
- ✅ No game client needed on server
- ✅ Message history preserved
- ✅ Can add @mentions if needed

### Solution 2: AutoHotkey In-Game Messages

If you MUST have in-game messages, this works but requires keeping a game client running on the server:

**Setup:**

```powershell
# Run this once to install AutoHotkey
.\Setup-AutoHotkey-Solution.ps1

# Then use the original script
.\Restart-Icarus.ps1
```

**Requirements:**

- Icarus game client must be running on server
- Must be logged in to your server as admin
- Game can be minimized but must stay running
- AutoHotkey installed (C:\Program Files\AutoHotkey\)

**How it works:**

1. Script activates the Icarus window
2. Opens chat (Enter key)
3. Types `/AdminSay Your Message`
4. Sends it (Enter key)

This is hacky but it DOES work for true in-game notifications.

### Solution 3: Manual Warnings

If neither automated solution works:

```powershell
# Start script with delay
.\Restart-IcarusServer.ps1 -WaitMinutes 15

# Then immediately:
# 1. Join your server
# 2. Type: /AdminLogin YourPassword
# 3. Send warnings manually in chat
```

## Configuration

The script uses these defaults:

```powershell
$ServiceName = "IcarusServer"  # Your Windows service name
```

If your service has a different name, edit the script or check available services:

```powershell
Get-Service | Where-Object {$_.Name -like "*Icarus*"}
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
# Run as Administrator (update path if your scripts are elsewhere)
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
# Run at 3 AM daily (update path if your scripts are elsewhere)
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

The Icarus server may not be running as a Windows Service. Check what's actually running:

```powershell
# Check for IcarusServer process
Get-Process | Where-Object {$_.Name -like "*Icarus*"}

# Check all services (not just Icarus)
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object Name, DisplayName

# If it's a process, not a service, you'll need to use process management instead
```

**If Icarus is running as a PROCESS (not a service):**

You'll need to modify the restart scripts to use `Stop-Process` and `Start-Process` instead of service commands. The scripts currently assume a Windows Service exists.

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
