# Install-As-Service.ps1
# Converts Icarus server to run as a Windows service

param(
    [string]$ServerPath = "C:\Users\newdark\icarus",
    [string]$ServiceName = "IcarusServer"
)

$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

function Write-ColorOutput($Color, $Message) {
    Write-Host "$Color$Message$Reset"
}

Write-ColorOutput $Cyan "`n=== Icarus Server - Install as Windows Service ===`n"

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-ColorOutput $Red "ERROR: This script must be run as Administrator!"
    Write-ColorOutput $Yellow "Right-click PowerShell and select 'Run as Administrator'`n"
    exit 1
}

# Find IcarusServer.exe
$serverExe = Join-Path $ServerPath "IcarusServer.exe"
if (-not (Test-Path $serverExe)) {
    Write-ColorOutput $Red "ERROR: IcarusServer.exe not found at: $serverExe"
    Write-ColorOutput $Yellow "Please specify the correct path with -ServerPath parameter`n"
    exit 1
}

Write-ColorOutput $Green "✓ Found IcarusServer.exe at: $serverExe`n"

# Check if service already exists
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-ColorOutput $Yellow "Service '$ServiceName' already exists!"
    $response = Read-Host "Do you want to remove and recreate it? (y/n)"
    if ($response -ne 'y') {
        Write-ColorOutput $Yellow "Aborted.`n"
        exit 0
    }

    Write-ColorOutput $Yellow "Stopping and removing existing service..."
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName
    Start-Sleep -Seconds 2
}

# Download NSSM (Non-Sucking Service Manager) if not present
$nssmPath = Join-Path $env:TEMP "nssm-2.24"
$nssmExe = Join-Path $nssmPath "win64\nssm.exe"

if (-not (Test-Path $nssmExe)) {
    Write-ColorOutput $Yellow "Downloading NSSM (service wrapper)..."
    $nssmZip = Join-Path $env:TEMP "nssm-2.24.zip"

    try {
        Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip
        Expand-Archive -Path $nssmZip -DestinationPath $env:TEMP -Force
        Write-ColorOutput $Green "✓ NSSM downloaded`n"
    } catch {
        Write-ColorOutput $Red "Failed to download NSSM: $($_.Exception.Message)"
        Write-ColorOutput $Yellow "Please download manually from: https://nssm.cc/download`n"
        exit 1
    }
}

# Create the service
Write-ColorOutput $Yellow "Creating Windows service..."
try {
    # Install service with NSSM
    & $nssmExe install $ServiceName $serverExe

    # Configure service settings
    & $nssmExe set $ServiceName AppDirectory $ServerPath
    & $nssmExe set $ServiceName AppParameters '-Log -SteamServerName="The Dream Team"'
    & $nssmExe set $ServiceName DisplayName "The Dream Team"
    & $nssmExe set $ServiceName Description "The Dream Team - Icarus dedicated game server"
    & $nssmExe set $ServiceName Start SERVICE_AUTO_START

    # Configure restart behavior (restart on failure)
    & $nssmExe set $ServiceName AppStopMethodConsole 1500
    & $nssmExe set $ServiceName AppStopMethodWindow 1500
    & $nssmExe set $ServiceName AppStopMethodThreads 1500
    & $nssmExe set $ServiceName AppExit Default Restart

    Write-ColorOutput $Green "`n✓ Service created successfully!`n"
} catch {
    Write-ColorOutput $Red "Failed to create service: $($_.Exception.Message)`n"
    exit 1
}

# Start the service
Write-ColorOutput $Yellow "Starting service..."
try {
    Start-Service -Name $ServiceName
    Start-Sleep -Seconds 3

    $service = Get-Service -Name $ServiceName
    if ($service.Status -eq 'Running') {
        Write-ColorOutput $Green "✓ Service is running!`n"
    } else {
        Write-ColorOutput $Yellow "Service status: $($service.Status)`n"
    }
} catch {
    Write-ColorOutput $Red "Failed to start service: $($_.Exception.Message)`n"
}

# Summary
Write-ColorOutput $Cyan "=== Setup Complete ===`n"
Write-ColorOutput $Green "Service Name: $ServiceName"
Write-ColorOutput $Green "Executable: $serverExe"
Write-ColorOutput $Green "Startup Type: Automatic (starts with Windows)"
Write-ColorOutput $Green "`nService commands:"
Write-Host "  Start-Service -Name $ServiceName" -ForegroundColor White
Write-Host "  Stop-Service -Name $ServiceName" -ForegroundColor White
Write-Host "  Restart-Service -Name $ServiceName" -ForegroundColor White
Write-Host "  Get-Service -Name $ServiceName`n" -ForegroundColor White

Write-ColorOutput $Yellow "Now you can use the restart scripts!"
Write-Host "  .\Restart-IcarusServer.ps1`n" -ForegroundColor White
