# reMarkable Wallpaper Manager installer script for Windows
# Copies rm-background-manager folder to remote reMarkable tablet

# Define separator
$SEPARATOR = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Welcome header
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host "        reMarkable Wallpaper Manager Installer" -ForegroundColor Cyan
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host
Write-Host "Welcome to " -NoNewline
Write-Host "reMarkable Wallpaper Manager!" -ForegroundColor White
Write-Host "For updates and more information, visit:"
Write-Host "https://github.com/ambercaravalho/rM-Wallpaper-Manager" -ForegroundColor Cyan
Write-Host

# Important information section
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "• If you are using a reMarkable Paper Pro, you must enable developer mode:" -ForegroundColor Yellow
Write-Host "  https://support.remarkable.com/s/article/Developer-mode" -ForegroundColor Cyan
Write-Host "• On reMarkable 2 or Paper Pro, please enable full device encryption:" -ForegroundColor Yellow
Write-Host "  Settings > Security > Data Protection > Security Level" -ForegroundColor Yellow
Write-Host

Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host "                Installation Process" -ForegroundColor Cyan
Write-Host $SEPARATOR -ForegroundColor Cyan
Write-Host

# Check if rm-background-manager folder exists
if (-Not (Test-Path -Path "rm-background-manager" -PathType Container)) {
    Write-Host "Error: " -ForegroundColor Red -NoNewline
    Write-Host "rm-background-manager folder not found in current directory." -ForegroundColor Red
    Write-Host "Please redownload the repository from GitHub and run the start script again." -ForegroundColor Red
    exit 1
}

# Get the IP address of the reMarkable
Write-Host "Step 1: " -NoNewline
Write-Host "Enter your device information"
$REMARKABLE_IP = Read-Host "Enter your reMarkable's IP address"

# Copy files to the reMarkable
Write-Host
Write-Host "Step 2: " -NoNewline
Write-Host "Copying files to your reMarkable tablet..."
Write-Host "Note: " -ForegroundColor Yellow -NoNewline
Write-Host "You'll need to enter the password when prompted (found in your device's settings)."

try {
    # Using pscp.exe (PuTTY SCP) which should be installed separately
    # Alternatively, users can install OpenSSH client feature in Windows 10/11
    if (Get-Command pscp.exe -ErrorAction SilentlyContinue) {
        pscp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
    } elseif (Get-Command scp.exe -ErrorAction SilentlyContinue) {
        scp.exe -r rm-background-manager root@${REMARKABLE_IP}:/home/root/
    } else {
        throw "Neither pscp.exe nor scp.exe was found. Please install PuTTY or OpenSSH Client."
    }
    
    Write-Host
    Write-Host "✓ Success! " -ForegroundColor Green -NoNewline
    Write-Host "rm-background-manager has been installed to your reMarkable." -ForegroundColor Green
    Write-Host "Connect to your device using SSH to run the application." -ForegroundColor Green
} catch {
    Write-Host
    Write-Host "✗ Error: " -ForegroundColor Red -NoNewline
    Write-Host "Failed to copy files to the reMarkable." -ForegroundColor Red
    Write-Host "Please check the IP address and make sure your tablet is connected to your computer." -ForegroundColor Red
    Write-Host "Technical error: $_" -ForegroundColor Red
}
