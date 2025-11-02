# reMarkable Wallpaper Manager - Installation Script
# Copies wallpaper manager to your reMarkable tablet
# For updates: https://github.com/ambercaravalho/rM-Wallpaper-Manager

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Constants
$SEPARATOR = "━" * 60
$BACKGROUND_FILES = @(
    "batteryempty.png", "factory.png", "hibernate.png",
    "overheating.png", "poweroff.png", "rebooting.png",
    "restart-crashed.png", "starting.png", "suspended.png"
)

# Device resolutions
$DEVICE_RESOLUTIONS = @{
    'rM1' = @{ Width = 1404; Height = 1872 }
    'rM2' = @{ Width = 1404; Height = 1872 }
    'rMPro' = @{ Width = 1872; Height = 2404 }
    'rMProMove' = @{ Width = 1696; Height = 954 }
}

# Global device dimensions
$script:DeviceWidth = 1404
$script:DeviceHeight = 1872

# Functions
function Show-Header {
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host "    reMarkable Wallpaper Manager" -ForegroundColor Cyan
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host
}

function Show-ImportantInfo {
    Write-Host "Before You Start:" -ForegroundColor Yellow
    Write-Host
    Write-Host "Paper Pro users: " -NoNewline -ForegroundColor Yellow
    Write-Host "Enable developer mode first"
    Write-Host "  → https://support.remarkable.com/s/article/Developer-mode" -ForegroundColor Cyan
    Write-Host
    Write-Host "Security recommendation: " -NoNewline -ForegroundColor Yellow
    Write-Host "Enable device encryption"
    Write-Host "  Settings → Security → Data Protection"
    Write-Host
}

function Test-Prerequisites {
    if (-Not (Test-Path "rm-background-manager" -PathType Container)) {
        Write-Host "✗ Error: " -ForegroundColor Red -NoNewline
        Write-Host "Missing rm-background-manager folder"
        Write-Host "  Please run this script from the repository root" -ForegroundColor Red
        exit 1
    }
}

function Test-ImageCapabilities {
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "Note: " -ForegroundColor Yellow -NoNewline
        Write-Host "Image conversion not available"
        Write-Host "Images will be copied without resizing" -ForegroundColor Yellow
        Write-Host
        return $false
    }
}

function Convert-AndResizeImage {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Width,
        [int]$Height
    )
    
    Write-Host "  Processing image..." -ForegroundColor Cyan
    
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        
        $original = [System.Drawing.Image]::FromFile($SourcePath)
        $resized = New-Object System.Drawing.Bitmap($Width, $Height)
        $graphics = [System.Drawing.Graphics]::FromImage($resized)
        $graphics.Clear([System.Drawing.Color]::White)
        
        # Calculate aspect ratio
        $ratioX = $Width / $original.Width
        $ratioY = $Height / $original.Height
        $ratio = [Math]::Min($ratioX, $ratioY)
        
        $newWidth = [int]($original.Width * $ratio)
        $newHeight = [int]($original.Height * $ratio)
        $posX = [int](($Width - $newWidth) / 2)
        $posY = [int](($Height - $newHeight) / 2)
        
        $graphics.DrawImage($original, $posX, $posY, $newWidth, $newHeight)
        $resized.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Cleanup
        $graphics.Dispose()
        $resized.Dispose()
        $original.Dispose()
        
        Write-Host "  ✓ Image converted successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  Warning: Conversion failed, copying original" -ForegroundColor Yellow
        Copy-Item -Path $SourcePath -Destination $DestPath -Force
    }
}

function Select-DeviceModel {
    Write-Host "Select Your Device:" -ForegroundColor White
    Write-Host
    Write-Host "1. reMarkable 1"
    Write-Host "2. reMarkable 2"
    Write-Host "3. reMarkable Paper Pro"
    Write-Host "4. reMarkable Paper Pro Move"
    Write-Host
    
    $choice = Read-Host "Your choice (1-4)"
    
    switch ($choice) {
        "1" {
            Write-Host "✓ reMarkable 1 selected" -ForegroundColor Green
            $script:DeviceWidth = $DEVICE_RESOLUTIONS['rM1'].Width
            $script:DeviceHeight = $DEVICE_RESOLUTIONS['rM1'].Height
        }
        "2" {
            Write-Host "✓ reMarkable 2 selected" -ForegroundColor Green
            $script:DeviceWidth = $DEVICE_RESOLUTIONS['rM2'].Width
            $script:DeviceHeight = $DEVICE_RESOLUTIONS['rM2'].Height
        }
        "3" {
            Write-Host "✓ reMarkable Paper Pro selected" -ForegroundColor Green
            $script:DeviceWidth = $DEVICE_RESOLUTIONS['rMPro'].Width
            $script:DeviceHeight = $DEVICE_RESOLUTIONS['rMPro'].Height
        }
        "4" {
            Write-Host "✓ reMarkable Paper Pro Move selected" -ForegroundColor Green
            $script:DeviceWidth = $DEVICE_RESOLUTIONS['rMProMove'].Width
            $script:DeviceHeight = $DEVICE_RESOLUTIONS['rMProMove'].Height
        }
        default {
            Write-Host "Invalid selection, defaulting to reMarkable 2" -ForegroundColor Yellow
            $script:DeviceWidth = $DEVICE_RESOLUTIONS['rM2'].Width
            $script:DeviceHeight = $DEVICE_RESOLUTIONS['rM2'].Height
        }
    }
    Write-Host
}

function Show-ModeMenu {
    Write-Host "Choose Installation Mode:" -ForegroundColor White
    Write-Host
    Write-Host "1. Guided - Select images interactively"
    Write-Host "2. Manual - Use pre-prepared images"
    Write-Host "3. Exit"
    Write-Host
    
    return Read-Host "Your choice (1-3)"
}

function Get-BackgroundDescription {
    param([string]$FileName)
    
    $descriptions = @{
        "batteryempty.png" = "Battery depleted screen"
        "factory.png" = "Factory reset screen"
        "hibernate.png" = "Deep sleep mode"
        "overheating.png" = "Overheating warning"
        "poweroff.png" = "Power off screen"
        "rebooting.png" = "Reboot screen"
        "restart-crashed.png" = "Crash recovery screen"
        "starting.png" = "Boot/startup screen"
        "suspended.png" = "Sleep/suspend screen"
    }
    
    return $descriptions[$FileName] ?? "System background"
}

function Start-GuidedInstallation {
    Write-Host
    Write-Host "Guided Wallpaper Setup" -ForegroundColor Cyan
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host
    
    Select-DeviceModel
    
    $hasImageCapabilities = Test-ImageCapabilities
    
    $customBgPath = "rm-background-manager\custom-backgrounds"
    if (-Not (Test-Path $customBgPath)) {
        New-Item -Path $customBgPath -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  • Drag and drop image files into the terminal"
    Write-Host "  • Type 'skip' to keep default background"
    if ($hasImageCapabilities) {
        Write-Host "  • Images will be auto-converted and resized"
    }
    Write-Host
    
    $addedCount = 0
    foreach ($bgFile in $BACKGROUND_FILES) {
        Write-Host $bgFile -ForegroundColor White
        Write-Host "  $(Get-BackgroundDescription $bgFile)"
        $imagePath = Read-Host "  Image path (or 'skip')"
        
        if ($imagePath -eq 'skip') {
            Write-Host "  Skipped" -ForegroundColor Yellow
            Write-Host
            continue
        }
        
        $imagePath = $imagePath -replace '["`'']', ''
        
        if (-Not (Test-Path $imagePath -PathType Leaf)) {
            Write-Host "  ✗ File not found, skipping" -ForegroundColor Red
            Write-Host
            continue
        }
        
        if ($imagePath -notmatch '\.(png|jpg|jpeg|gif|bmp|tiff)$') {
            Write-Host "  ✗ Not a supported image format, skipping" -ForegroundColor Red
            Write-Host
            continue
        }
        
        $destFile = Join-Path $customBgPath $bgFile
        
        if ($hasImageCapabilities) {
            Convert-AndResizeImage -SourcePath $imagePath -DestPath $destFile -Width $script:DeviceWidth -Height $script:DeviceHeight
        }
        else {
            Copy-Item -Path $imagePath -Destination $destFile -Force
        }
        
        Write-Host "  ✓ Added $bgFile" -ForegroundColor Green
        Write-Host
        $addedCount++
    }
    
    if ($addedCount -eq 0) {
        Write-Host "No images added. Please prepare images manually." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "✓ Prepared $addedCount custom background(s)" -ForegroundColor Green
    Write-Host
}

function Copy-ToReMarkable {
    param([string]$IpAddress)
    
    Write-Host
    Write-Host "Copying files to reMarkable..." -ForegroundColor White
    Write-Host "Enter your SSH password when prompted" -ForegroundColor Yellow
    Write-Host "(Find it in: Settings → Copyrights and licenses → GPLv3)" -ForegroundColor Yellow
    Write-Host
    
    $scpCommand = $null
    if (Get-Command scp.exe -ErrorAction SilentlyContinue) {
        $scpCommand = "scp.exe"
    }
    elseif (Get-Command pscp.exe -ErrorAction SilentlyContinue) {
        $scpCommand = "pscp.exe"
    }
    else {
        throw "No SCP client found. Please install OpenSSH Client or PuTTY."
    }
    
    try {
        $process = Start-Process -FilePath $scpCommand -ArgumentList "-r", "rm-background-manager", "root@${IpAddress}:/home/root/" -Wait -NoNewWindow -PassThru
        
        if ($process.ExitCode -eq 0) {
            return $true
        }
    }
    catch {
        # Try to fix SSH key issue
        Write-Host "Fixing SSH key issue..." -ForegroundColor Yellow
        if (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue) {
            ssh-keygen.exe -R $IpAddress 2>&1 | Out-Null
            
            $process = Start-Process -FilePath $scpCommand -ArgumentList "-r", "rm-background-manager", "root@${IpAddress}:/home/root/" -Wait -NoNewWindow -PassThru
            
            return ($process.ExitCode -eq 0)
        }
    }
    
    return $false
}

function Connect-ToReMarkable {
    param([string]$IpAddress)
    
    Write-Host
    Write-Host "✓ Files copied successfully!" -ForegroundColor Green
    Write-Host
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host "Next Steps" -ForegroundColor Cyan
    Write-Host $SEPARATOR -ForegroundColor Cyan
    Write-Host
    Write-Host "Once connected to your reMarkable:"
    Write-Host "  1. cd /home/root/rm-background-manager"
    Write-Host "  2. bash wallpaper-manager.sh"
    Write-Host
    Write-Host "Connecting via SSH..." -ForegroundColor White
    Write-Host
    
    if (Get-Command ssh.exe -ErrorAction SilentlyContinue) {
        ssh.exe "root@$IpAddress"
    }
    elseif (Get-Command plink.exe -ErrorAction SilentlyContinue) {
        plink.exe -ssh "root@$IpAddress"
    }
    else {
        Write-Host "Warning: No SSH client found" -ForegroundColor Yellow
        Write-Host "Please connect manually to: root@$IpAddress" -ForegroundColor Yellow
    }
}

# Main execution
function Main {
    Show-Header
    Show-ImportantInfo
    Test-Prerequisites
    
    $modeChoice = Show-ModeMenu
    
    switch ($modeChoice) {
        "1" {
            Start-GuidedInstallation
        }
        "2" {
            Write-Host "Using manual mode with existing files" -ForegroundColor Cyan
            Write-Host
        }
        "3" {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host "Invalid option, defaulting to manual mode" -ForegroundColor Yellow
            Write-Host
        }
    }
    
    $remarkableIp = Read-Host "Enter your reMarkable's IP address"
    
    if (Copy-ToReMarkable -IpAddress $remarkableIp) {
        Connect-ToReMarkable -IpAddress $remarkableIp
    }
    else {
        Write-Host
        Write-Host "✗ Failed to copy files" -ForegroundColor Red
        Write-Host "Check your IP address and device connection" -ForegroundColor Red
        exit 1
    }
}

# Run the script
Main
