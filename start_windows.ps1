# reMarkable Wallpaper Manager installer script for Windows
# Copies rm-background-manager folder to remote reMarkable tablet

Write-Host "Welcome to reMarkable Wallpaper Manager!" -ForegroundColor Cyan
Write-Host "For updates and more information, visit:" -ForegroundColor Cyan
Write-Host "https://github.com/ambercaravalho/rM-Wallpaper-Manager" -ForegroundColor Cyan
Write-Host
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "- If you are using a reMarkable Paper Pro, you must enable developer mode:" -ForegroundColor Yellow
Write-Host "  https://support.remarkable.com/s/article/Developer-mode" -ForegroundColor Yellow
Write-Host "- On reMarkable 2 or Paper Pro, please enable full device encryption before doing anything else with your device (this is technically optional):" -ForegroundColor Yellow
Write-Host "  Settings > Security > Data Protection > Security Level" -ForegroundColor Yellow
Write-Host

Write-Host "reMarkable Background Manager Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host

# Check if rm-background-manager folder exists
if (-Not (Test-Path -Path "rm-background-manager" -PathType Container)) {
    Write-Host "Error: rm-background-manager folder not found in current directory." -ForegroundColor Red
    Write-Host "Please redownload the repository from GitHub and run the start script again." -ForegroundColor Red
    exit 1
}

# Get the IP address of the reMarkable
$REMARKABLE_IP = Read-Host "Enter your reMarkable's IP address"

# Copy files to the reMarkable
Write-Host "Copying files to your reMarkable tablet..."
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
    
    Write-Host "Success! rm-background-manager has been installed to your reMarkable." -ForegroundColor Green
    Write-Host "Connect to your device using SSH to run the application." -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to copy files to the reMarkable." -ForegroundColor Red
    Write-Host "Please check the IP address and make sure your tablet is connected to your computer over USB." -ForegroundColor Red
    Write-Host "Note: You'll need to enter the password when prompted (found in your device's settings)." -ForegroundColor Red
    Write-Host "Technical error: $_" -ForegroundColor Red
}
